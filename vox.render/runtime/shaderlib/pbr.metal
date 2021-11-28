//
//  pbr.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/23.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.metal"

typedef struct {
    float4 position [[position]];
    float3 v_pos [[function_constant(needWorldPos)]];
    float2 v_uv;
    float4 v_color [[function_constant(hasVertexColor)]];
    float3 normalW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 tangentW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 bitangentW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 v_normal [[function_constant(hasNormalNotHasTangentOrHasNormalTexture)]];
} VertexOut;

#define EPSILON 1e-6
#define RECIPROCAL_PI 0.31830988618
#define MAXIMUM_SPECULAR_COEFFICIENT 0.16
#define DEFAULT_SPECULAR_COEFFICIENT 0.04

#define RE_Direct            RE_Direct_Physical
#define RE_IndirectDiffuse   RE_IndirectDiffuse_Physical
#define RE_IndirectSpecular  RE_IndirectSpecular_Physical
#define Material_BlinnShininessExponent( material )   GGXRoughnessToBlinnExponent( material.specularRoughness )

float4 SRGBtoLINEAR(float4 srgbIn) {
    return srgbIn;
}

float pow2( const float x ) {
    return x * x;
}

float3 inverseTransformDirection( float3 dir, matrix_float4x4 matrix ) {
    return normalize( ( float4( dir, 0.0 ) * matrix ).xyz );
}

float3 BRDF_Diffuse_Lambert( const float3 diffuseColor ) {
    return RECIPROCAL_PI * diffuseColor;
}

// source: http://simonstechblog.blogspot.ca/2011/12/microfacet-brdf.html
float GGXRoughnessToBlinnExponent( const float ggxRoughness ) {
    return ( 2.0 / pow2( ggxRoughness + 0.0001 ) - 2.0 );
}

float computeSpecularOcclusion( const float dotNV, const float ambientOcclusion, const float roughness ) {
    return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );
}

typedef struct {
    float3 color;
    float3 direction;
} DirectLight;

typedef struct {
    float3 color;
    float3 position;
    float distance;
} PointLight;

typedef struct {
    float3 color;
    float3 position;
    float3 direction;
    float distance;
    float angleCos;
    float penumbraCos;
} SpotLight;

typedef struct {
    float3 color;
    float3 direction;
} IncidentLight;

typedef struct {
    float3 directDiffuse;
    float3 directSpecular;
    float3 indirectDiffuse;
    float3 indirectSpecular;
} ReflectedLight;

typedef struct {
    float3 position;
    float3 normal;
    float3 viewDir;
} GeometricContext;

typedef struct {
    float3    diffuseColor;
    float     specularRoughness;
    float3    specularColor;
} PhysicalMaterial;

float3 getPbrNormal(VertexOut in, float u_normalIntensity,
                    sampler smp, texture2d<float> u_normalTexture,
                    bool is_front_face) {
    float3 n;
    if (hasNormalTexture) {
        matrix_float3x3 tbn;
        if (!hasTangent) {
            float3 pos_dx = dfdx(in.v_pos);
            float3 pos_dy = dfdy(in.v_pos);
            float3 tex_dx = dfdx(float3(in.v_uv, 0.0));
            float3 tex_dy = dfdy(float3(in.v_uv, 0.0));
            float3 t = (tex_dy.y * pos_dx - tex_dx.x * pos_dy) / (tex_dx.x * tex_dy.y - tex_dy.x * tex_dx.y);//fix
            float3 ng;
            if (hasNormal) {
                ng = normalize(in.v_normal);
            } else {
                ng = normalize( cross(pos_dx, pos_dy) );
            }
            t = normalize(t - ng * dot(ng, t));
            float3 b = normalize(cross(ng, t));
            tbn = matrix_float3x3(t, b, ng);
        } else {
            tbn = matrix_float3x3(in.normalW, in.tangentW, in.bitangentW);
        }
        n = u_normalTexture.sample(smp, in.v_uv).rgb;
        n = normalize(tbn * ((2.0 * n - 1.0) * float3(u_normalIntensity, u_normalIntensity, 1.0)));
    } else {
        if (hasNormal) {
            n = normalize(in.v_normal);
        } else {
            float3 pos_dx = dfdx(in.v_pos);
            float3 pos_dy = dfdy(in.v_pos);
            n = normalize( cross(pos_dx, pos_dy) );
        }
    }
    
    n *= float( !is_front_face ) * 2.0 - 1.0;
    return n;
}

//MARK: - pbr_brdf_cook_torrance_frag_define
float3 F_Schlick( const float3 specularColor, const float dotLH ) {
    // Original approximation by Christophe Schlick '94
    // float fresnel = pow( 1.0 - dotLH, 5.0 );
    
    // Optimized variant (presented by Epic at SIGGRAPH '13)
    // https://cdn2.unrealengine.com/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf
    float fresnel = exp2( ( -5.55473 * dotLH - 6.98316 ) * dotLH );
    
    return ( 1.0 - specularColor ) * fresnel + specularColor;
}

// Moving Frostbite to Physically Based Rendering 3.0 - page 12, listing 2
// https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
float G_GGX_SmithCorrelated( const float alpha, const float dotNL, const float dotNV ) {
    
    float a2 = pow2( alpha );
    
    // dotNL and dotNV are explicitly swapped. This is not a mistake.
    float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
    float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );
    
    return 0.5 / max( gv + gl, EPSILON );
    
}

// Microfacet Models for Refraction through Rough Surfaces - equation (33)
// http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
// alpha is "roughness squared" in Disney’s reparameterization
float D_GGX( const float alpha, const float dotNH ) {
    
    float a2 = pow2( alpha );
    
    float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0; // avoid alpha = 0 with dotNH = 1
    
    return RECIPROCAL_PI * a2 / pow2( denom );
    
}

// GGX Distribution, Schlick Fresnel, GGX-Smith Visibility
float3 BRDF_Specular_GGX( const IncidentLight incidentLight, const GeometricContext geometry,
                         const float3 specularColor, const float roughness ) {
    
    float alpha = pow2( roughness ); // UE4's roughness
    
    float3 halfDir = normalize( incidentLight.direction + geometry.viewDir );
    
    float dotNL = saturate( dot( geometry.normal, incidentLight.direction ) );
    float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
    float dotNH = saturate( dot( geometry.normal, halfDir ) );
    float dotLH = saturate( dot( incidentLight.direction, halfDir ) );
    
    float3 F = F_Schlick( specularColor, dotLH );
    
    float G = G_GGX_SmithCorrelated( alpha, dotNL, dotNV );
    
    float D = D_GGX( alpha, dotNH );
    
    return F * ( G * D );
    
} // validated

//MARK: - pbr_direct_irradiance_frag_define
void RE_Direct_Physical(const IncidentLight directLight, const GeometricContext geometry,
                        const PhysicalMaterial material, thread ReflectedLight &reflectedLight ) {
    
    float dotNL = saturate( dot( geometry.normal, directLight.direction ) );
    
    float3 irradiance = dotNL * directLight.color;
    
#ifndef PHYSICALLY_CORRECT_LIGHTS
    irradiance *= M_PI_F; // punctual light
#endif
    
    reflectedLight.directSpecular += irradiance * BRDF_Specular_GGX(directLight, geometry,
                                                                    material.specularColor, material.specularRoughness );
    
    reflectedLight.directDiffuse += irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );
}

void getDirectionalDirectLightIrradiance(const DirectLight directionalLight, const GeometricContext geometry,
                                         thread IncidentLight &directLight ) {
    directLight.color = directionalLight.color;
    directLight.direction = -directionalLight.direction;
}

// directLight is an out parameter as having it as a return value caused compiler errors on some devices
void getPointDirectLightIrradiance(const PointLight pointLight, const GeometricContext geometry,
                                   thread IncidentLight &directLight ) {
    float3 lVector = pointLight.position - geometry.position;
    directLight.direction = normalize( lVector );
    
    float lightDistance = length( lVector );
    
    directLight.color = pointLight.color;
    directLight.color *= clamp(1.0 - pow(lightDistance/pointLight.distance, 4.0), 0.0, 1.0);
}

// directLight is an out parameter as having it as a return value caused compiler errors on some devices
void getSpotDirectLightIrradiance(const SpotLight spotLight, const GeometricContext geometry,
                                  thread IncidentLight &directLight  ) {
    float3 lVector = spotLight.position - geometry.position;
    directLight.direction = normalize( lVector );
    
    float lightDistance = length( lVector );
    float angleCos = dot( directLight.direction, -spotLight.direction );
    
    float spotEffect = smoothstep( spotLight.penumbraCos, spotLight.angleCos, angleCos );
    float decayEffect = clamp(1.0 - pow(lightDistance/spotLight.distance, 4.0), 0.0, 1.0);
    
    directLight.color = spotLight.color;
    directLight.color *= spotEffect * decayEffect;
}

//MARK: - pbr_ibl_diffuse_frag_define
void RE_IndirectDiffuse_Physical(const float3 irradiance, const GeometricContext geometry, const PhysicalMaterial material,
                                 thread ReflectedLight &reflectedLight ) {
    reflectedLight.indirectDiffuse += irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );
}

// sh need be pre-scaled in CPU.
float3 getLightProbeIrradiance(constant float3 *sh, float3 normal){
    float3 result = sh[0] +
    sh[1] * (normal.y) +
    sh[2] * (normal.z) +
    sh[3] * (normal.x) +
    
    sh[4] * (normal.y * normal.x) +
    sh[5] * (normal.y * normal.z) +
    sh[6] * (3.0 * normal.z * normal.z - 1.0) +
    sh[7] * (normal.z * normal.x) +
    sh[8] * (normal.x * normal.x - normal.y * normal.y);
    
    return max(result, float3(0.0));
}

//MARK: - pbr_ibl_specular_frag_define
// ref: https://www.unrealengine.com/blog/physically-based-shading-on-mobile - environmentBRDF for GGX on mobile
float3 BRDF_Specular_GGX_Environment(const GeometricContext geometry, const float3 specularColor, const float roughness ) {
    float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
    
    const float4 c0 = float4( - 1, - 0.0275, - 0.572, 0.022 );
    
    const float4 c1 = float4( 1, 0.0425, 1.04, - 0.04 );
    
    float4 r = roughness * c0 + c1;
    
    float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;
    
    float2 AB = float2( -1.04, 1.04 ) * a004 + r.zw;
    
    return specularColor * AB.x + AB.y;
} // validated

// taken from here: http://casual-effects.blogspot.ca/2011/08/plausible-environment-lighting-in-two.html
float getSpecularMIPLevel(const float blinnShininessExponent, const int maxMIPLevel ) {
    //float envMapWidth = pow( 2.0, maxMIPLevelScalar );
    //float desiredMIPLevel = log2( envMapWidth * sqrt( 3.0 ) ) - 0.5 * log2( pow2( blinnShininessExponent ) + 1.0 );
    
    float maxMIPLevelScalar = float( maxMIPLevel );
    float desiredMIPLevel = maxMIPLevelScalar + 0.79248 - 0.5 * log2( pow2( blinnShininessExponent ) + 1.0 );
    
    // clamp to allowable LOD ranges.
    return clamp( desiredMIPLevel, 0.0, maxMIPLevelScalar );
}

float3 getLightProbeIndirectRadiance(const GeometricContext geometry, const float blinnShininessExponent, const int maxMIPLevel,
                                     texturecube<float> u_env_specularTexture, sampler textureSampler, EnvMapLight u_envMapLight ) {
    if (hasSpecularEnv) {
        return float3(0.0);
    } else {
        float3 reflectVec = reflect( -geometry.viewDir, geometry.normal );
        
        float specularMIPLevel = getSpecularMIPLevel( blinnShininessExponent, maxMIPLevel );
        float4 envMapColor = u_env_specularTexture.sample(textureSampler, reflectVec, level(specularMIPLevel));
        
        envMapColor.rgb = SRGBtoLINEAR( envMapColor * u_envMapLight.specularIntensity).rgb;
        
        return envMapColor.rgb;
    }
}

void RE_IndirectSpecular_Physical(const float3 radiance, const GeometricContext geometry, const PhysicalMaterial material,
                                  thread ReflectedLight &reflectedLight ) {
    reflectedLight.indirectSpecular += radiance * BRDF_Specular_GGX_Environment(geometry, material.specularColor,
                                                                                material.specularRoughness );
}

fragment float4 fragment_pbr(VertexOut in [[stage_in]],
                             sampler textureSampler [[sampler(0)]],
                             // common_frag
                             constant matrix_float4x4 &u_localMat [[buffer(0)]],
                             constant matrix_float4x4 &u_modelMat [[buffer(1)]],
                             constant matrix_float4x4 &u_viewMat [[buffer(2)]],
                             constant matrix_float4x4 &u_projMat [[buffer(3)]],
                             constant matrix_float4x4 &u_MVMat [[buffer(4)]],
                             constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                             constant matrix_float4x4 &u_normalMat [[buffer(6)]],
                             constant float3 &u_cameraPos [[buffer(7)]],
                             // direct_light_frag
                             constant float3 *u_directLightColor [[buffer(10), function_constant(hasDirectLight)]],
                             constant float3 *u_directLightDirection [[buffer(11), function_constant(hasDirectLight)]],
                             // point_light_frag
                             constant float3 *u_pointLightColor [[buffer(12), function_constant(hasPointLight)]],
                             constant float3 *u_pointLightPosition [[buffer(13), function_constant(hasPointLight)]],
                             constant float *u_pointLightDistance [[buffer(14), function_constant(hasPointLight)]],
                             // spot_light_frag
                             constant float3 *u_spotLightColor [[buffer(15), function_constant(hasSpotLight)]],
                             constant float3 *u_spotLightPosition [[buffer(16), function_constant(hasSpotLight)]],
                             constant float3 *u_spotLightDirection [[buffer(17), function_constant(hasSpotLight)]],
                             constant float *u_spotLightDistance [[buffer(18), function_constant(hasSpotLight)]],
                             constant float *u_spotLightAngleCos [[buffer(19), function_constant(hasSpotLight)]],
                             constant float *u_spotLightPenumbraCos [[buffer(20), function_constant(hasSpotLight)]],
                             // pbr_envmap_light_frag_define
                             constant EnvMapLight &u_envMapLight [[buffer(8)]],
                             constant float3 *u_env_sh [[buffer(9), function_constant(hasSH)]],
                             texturecube<float> u_env_specularTexture [[texture(0), function_constant(hasSpecularEnv)]],
                             //pbr base frag define
                             constant float &u_alphaCutoff [[buffer(21)]],
                             constant float4 &u_baseColor [[buffer(22)]],
                             constant float &u_metal [[buffer(23)]],
                             constant float &u_roughness [[buffer(24)]],
                             constant float3 &u_specularColor [[buffer(25)]],
                             constant float &u_glossinessFactor [[buffer(26)]],
                             constant float3 &u_emissiveColor [[buffer(27)]],
                             constant float &u_normalIntensity [[buffer(28)]],
                             constant float &u_occlusionStrength [[buffer(29)]],
                             // pbr_texture_frag_define
                             texture2d<float> u_baseColorTexture [[texture(1), function_constant(hasBaseColorMap)]],
                             texture2d<float> u_normalTexture [[texture(2), function_constant(hasNormalTexture)]],
                             texture2d<float> u_emissiveTexture [[texture(3), function_constant(hasEmissiveMap)]],
                             texture2d<float> u_metallicTexture [[texture(4), function_constant(hasMetalMap)]],
                             texture2d<float> u_roughnessTexture [[texture(5), function_constant(hasRoughnessMap)]],
                             texture2d<float> u_specularTexture [[texture(6), function_constant(hasSpecularMap)]],
                             texture2d<float> u_glossinessTexture [[texture(7), function_constant(hasGlossinessMap)]],
                             texture2d<float> u_occlusionTexture [[texture(8), function_constant(hasOcclusionMap)]],
                             bool is_front_face [[front_facing]]) {
    //MARK: - pbr_begin_frag
    float3 normal = getPbrNormal(in, u_normalIntensity, textureSampler, u_normalTexture, is_front_face);
    float4 diffuseColor = u_baseColor;
    float3 totalEmissiveRadiance = u_emissiveColor;
    float metalnessFactor = u_metal;
    float roughnessFactor = u_roughness;
    float3 specularFactor = u_specularColor;
    float glossinessFactor = u_glossinessFactor;
    
    ReflectedLight reflectedLight = ReflectedLight{ float3( 0.0 ), float3( 0.0 ), float3( 0.0 ), float3( 0.0 ) };
    PhysicalMaterial material;
    GeometricContext geometry;
    IncidentLight directLight;
    
    if (hasBaseColorMap) {
        float4 baseMapColor = u_baseColorTexture.sample(textureSampler, in.v_uv );
        baseMapColor = SRGBtoLINEAR( baseMapColor );
        diffuseColor *= baseMapColor;
    }
    
    if (hasVertexColor) {
        diffuseColor *= in.v_color;
    }
    
    if (needAlphaCutoff) {
        if( diffuseColor.a < u_alphaCutoff ) {
            discard_fragment();
        }
    }
    
    if (hasRoughnessMap) {
        float4 roughMapColor = u_roughnessTexture.sample(textureSampler, in.v_uv);
        roughnessFactor *= roughMapColor.r;
    }
    
    if (hasMetalMap) {
        float4 metalMapColor = u_metallicTexture.sample(textureSampler, in.v_uv);
        metalnessFactor *= metalMapColor.r;
    }
    
    if (hasGlossinessMap) {
        float4 glossinessColor = u_glossinessTexture.sample(textureSampler, in.v_uv );
        glossinessFactor *= glossinessColor.a;
    }
    
    if (hasSpecularMap) {
        float4 specularColor = u_specularTexture.sample(textureSampler, in.v_uv );
        specularFactor *= specularColor.rgb;
    }
    
    if (isMetallicWorkFlow) {
        material.diffuseColor = diffuseColor.rgb * ( 1.0 - metalnessFactor );
        material.specularRoughness = clamp( roughnessFactor, 0.04, 1.0 );
        material.specularColor = mix( float3( MAXIMUM_SPECULAR_COEFFICIENT), diffuseColor.rgb, metalnessFactor );
    } else {
        float specularStrength = max( max( specularFactor.r, specularFactor.g ), specularFactor.b );
        material.diffuseColor = diffuseColor.rgb * ( 1.0 - specularStrength );
        material.specularRoughness = clamp( 1.0 - glossinessFactor, 0.04, 1.0 );
        material.specularColor = specularFactor;
    }
    
    geometry.position = in.v_pos;
    geometry.normal = normal;
    geometry.viewDir = normalize(u_cameraPos - in.v_pos);
    
    //MARK: - pbr_direct_irradiance_frag
    if (directLightCount > 0) {
        DirectLight directionalLight;
        for ( int i = 0; i < directLightCount; i ++ ) {
            directionalLight.color = u_directLightColor[i];
            directionalLight.direction = u_directLightDirection[i];
            
            getDirectionalDirectLightIrradiance( directionalLight, geometry, directLight );
            
            RE_Direct( directLight, geometry, material, reflectedLight );
        }
    }
    
    if (pointLightCount > 0) {
        PointLight pointLight;
        for ( int i = 0; i < pointLightCount; i ++ ) {
            pointLight.color = u_pointLightColor[i];
            pointLight.position = u_pointLightPosition[i];
            pointLight.distance = u_pointLightDistance[i];
            
            getPointDirectLightIrradiance( pointLight, geometry, directLight );
            
            RE_Direct( directLight, geometry, material, reflectedLight );
        }
    }
    
    if (spotLightCount > 0) {
        SpotLight spotLight;
        for ( int i = 0; i < spotLightCount; i ++ ) {
            spotLight.color = u_spotLightColor[i];
            spotLight.position = u_spotLightPosition[i];
            spotLight.direction = u_spotLightDirection[i];
            spotLight.distance = u_spotLightDistance[i];
            spotLight.angleCos = u_spotLightAngleCos[i];
            spotLight.penumbraCos = u_spotLightPenumbraCos[i];
            
            getSpotDirectLightIrradiance( spotLight, geometry, directLight );
            
            RE_Direct( directLight, geometry, material, reflectedLight );
        }
    }
    
    //MARK: - pbr_ibl_diffuse_frag
    float3 irradiance;
    if (hasSH) {
        irradiance = getLightProbeIrradiance(u_env_sh, normal) * u_envMapLight.diffuseIntensity;
    } else {
        irradiance = u_envMapLight.diffuse * u_envMapLight.diffuseIntensity;
    }
#ifndef PHYSICALLY_CORRECT_LIGHTS
    irradiance *= M_PI_F;
#endif
    
    RE_IndirectDiffuse_Physical( irradiance, geometry, material, reflectedLight );
    
    //MARK: - pbr_ibl_specular_frag
    float3 radiance = float3( 0.0 );
    radiance += getLightProbeIndirectRadiance(geometry, Material_BlinnShininessExponent( material ), int(u_envMapLight.mipMapLevel),
                                              u_env_specularTexture, textureSampler, u_envMapLight);
    RE_IndirectSpecular( radiance, geometry, material, reflectedLight );
    
    //MARK: - pbr_end_frag
    if (hasOcclusionMap) {
        float ambientOcclusion = (u_occlusionTexture.sample(textureSampler, in.v_uv).r - 1.0) * u_occlusionStrength + 1.0;
        reflectedLight.indirectDiffuse *= ambientOcclusion;
        
        if (hasSpecularEnv) {
            float dotNV = saturate(dot(geometry.normal, geometry.viewDir));
            reflectedLight.indirectSpecular *= computeSpecularOcclusion(dotNV, ambientOcclusion, material.specularRoughness);
        }
    }
    
    if (hasEmissiveMap) {
        float4 emissiveMapColor = u_emissiveTexture.sample(textureSampler, in.v_uv);
        emissiveMapColor = SRGBtoLINEAR(emissiveMapColor);
        totalEmissiveRadiance = emissiveMapColor.rgb;
    }
    
    float3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse
    + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;
    
    float4 finalColor = float4(outgoingLight, diffuseColor.a);
    
    //MARK: - gamma_frag
#ifdef GAMMA
    float gamma = 2.2;
    finalColor.rgb = pow(gl_FragColor.rgb, float3(1.0 / gamma));
#endif
    
    return finalColor;
}
