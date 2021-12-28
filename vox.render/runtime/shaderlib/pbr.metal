//
//  pbr.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/23.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.h"
#include "shadow_common.h"

typedef struct {
    float3 position [[attribute(Position)]];
    float3 NORMAL [[attribute(Normal), function_constant(notOmitNormalAndHasNormal)]];
    float4 COLOR_0 [[attribute(Color_0), function_constant(hasVertexColor)]];
    float4 WEIGHTS_0 [[attribute(Weights_0), function_constant(hasSkin)]];
    float4 JOINTS_0 [[attribute(Joints_0), function_constant(hasSkin)]];
    float4 TANGENT [[attribute(Tangent), function_constant(notOmitNormalAndHasTangent)]];
    float2 TEXCOORD_0 [[attribute(UV_0), function_constant(hasUV)]];
    float3 POSITION_BS0 [[attribute(10), function_constant(hasBlendShape)]];
    float3 POSITION_BS1 [[attribute(11), function_constant(hasBlendShape)]];
    float3 POSITION_BS2 [[attribute(12), function_constant(hasBlendShape)]];
    float3 POSITION_BS3 [[attribute(13), function_constant(hasBlendShape)]];
    float3 NORMAL_BS0 [[attribute(16), function_constant(hasBlendShapeAndHasBlendShapeNormal)]];
    float3 NORMAL_BS1 [[attribute(17), function_constant(hasBlendShapeAndHasBlendShapeNormal)]];
    float3 NORMAL_BS2 [[attribute(18), function_constant(hasBlendShapeAndHasBlendShapeNormal)]];
    float3 NORMAL_BS3 [[attribute(19), function_constant(hasBlendShapeAndHasBlendShapeNormal)]];
    float3 TANGENT_BS0 [[attribute(20), function_constant(hasBlendShapeAndhasBlendShapeTangent)]];
    float3 TANGENT_BS1 [[attribute(21), function_constant(hasBlendShapeAndhasBlendShapeTangent)]];
    float3 TANGENT_BS2 [[attribute(22), function_constant(hasBlendShapeAndhasBlendShapeTangent)]];
    float3 TANGENT_BS3 [[attribute(23), function_constant(hasBlendShapeAndhasBlendShapeTangent)]];
} VertexIn;

typedef struct {
    float4 position [[position]];
    float3 v_pos [[function_constant(needWorldPos)]];
    float2 v_uv;
    float4 v_color [[function_constant(hasVertexColor)]];
    float3 normalW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 tangentW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 bitangentW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 v_normal [[function_constant(hasNormalNotHasTangentOrHasNormalTexture)]];
    float3 view_pos;
} VertexOut;

vertex VertexOut vertex_pbr(const VertexIn in [[stage_in]],
                            constant matrix_float4x4 &u_localMat [[buffer(10)]],
                            constant matrix_float4x4 &u_modelMat [[buffer(11)]],
                            constant matrix_float4x4 &u_viewMat [[buffer(12)]],
                            constant matrix_float4x4 &u_projMat [[buffer(13)]],
                            constant matrix_float4x4 &u_MVMat [[buffer(14)]],
                            constant matrix_float4x4 &u_MVPMat [[buffer(15)]],
                            constant matrix_float4x4 &u_normalMat [[buffer(16)]],
                            constant float3 &u_cameraPos [[buffer(17)]],
                            constant float4 &u_tilingOffset [[buffer(18)]],
                            constant matrix_float4x4 &u_viewMatFromLight [[buffer(19)]],
                            constant matrix_float4x4 &u_projMatFromLight [[buffer(20)]],
                            sampler u_jointSampler [[sampler(0), function_constant(hasSkinAndHasJointTexture)]],
                            texture2d<float> u_jointTexture [[texture(0), function_constant(hasSkinAndHasJointTexture)]],
                            constant int &u_jointCount [[buffer(21), function_constant(hasSkinAndHasJointTexture)]],
                            constant matrix_float4x4 *u_jointMatrix [[buffer(22), function_constant(hasSkinNotHasJointTexture)]],
                            constant float *u_blendShapeWeights [[buffer(23), function_constant(hasBlendShape)]]) {
    VertexOut out;
    
    // begin position
    float4 position = float4( in.position, 1.0);
    
    //begin normal
    float3 normal;
    float4 tangent;
    if (hasNormal) {
        normal = in.NORMAL;
        if (hasTangent && hasNormalTexture) {
            tangent = in.TANGENT;
        }
    }
    
    //blendshape
    if (hasBlendShape) {
        position.xyz += in.POSITION_BS0 * u_blendShapeWeights[0];
        position.xyz += in.POSITION_BS1 * u_blendShapeWeights[1];
        position.xyz += in.POSITION_BS2 * u_blendShapeWeights[2];
        position.xyz += in.POSITION_BS3 * u_blendShapeWeights[3];
        if (hasNormal && hasBlendShapeNormal) {
            normal.xyz += in.NORMAL_BS0 * u_blendShapeWeights[0];
            normal.xyz += in.NORMAL_BS1 * u_blendShapeWeights[1];
            normal.xyz += in.NORMAL_BS2 * u_blendShapeWeights[2];
            normal.xyz += in.NORMAL_BS3 * u_blendShapeWeights[3];
        }
        if (hasTangent && hasNormalTexture && hasBlendShapeTangent) {
            tangent.xyz += in.TANGENT_BS0 * u_blendShapeWeights[0];
            tangent.xyz += in.TANGENT_BS1 * u_blendShapeWeights[1];
            tangent.xyz += in.TANGENT_BS2 * u_blendShapeWeights[2];
            tangent.xyz += in.TANGENT_BS3 * u_blendShapeWeights[3];
        }
    }
    
    //skinning
    if (hasSkin) {
        matrix_float4x4 skinMatrix;
        if (hasJointTexture) {
            skinMatrix =
            in.WEIGHTS_0.x * getJointMatrix(u_jointSampler, u_jointTexture, in.JOINTS_0.x, u_jointCount) +
            in.WEIGHTS_0.y * getJointMatrix(u_jointSampler, u_jointTexture, in.JOINTS_0.y, u_jointCount) +
            in.WEIGHTS_0.z * getJointMatrix(u_jointSampler, u_jointTexture, in.JOINTS_0.z, u_jointCount) +
            in.WEIGHTS_0.w * getJointMatrix(u_jointSampler, u_jointTexture, in.JOINTS_0.w, u_jointCount);
        } else {
            skinMatrix =
            in.WEIGHTS_0.x * u_jointMatrix[int(in.JOINTS_0.x)] +
            in.WEIGHTS_0.y * u_jointMatrix[int(in.JOINTS_0.y)] +
            in.WEIGHTS_0.z * u_jointMatrix[int(in.JOINTS_0.z)] +
            in.WEIGHTS_0.w * u_jointMatrix[int(in.JOINTS_0.w)];
        }
        position = skinMatrix * position;
        if (hasNormal && !omitNormal) {
            normal = float4( skinMatrix * float4( normal, 0.0 ) ).xyz;
            if (hasTangent && hasNormalTexture) {
                tangent.xyz = float4( skinMatrix * float4( tangent.xyz, 0.0 ) ).xyz;
            }
        }
    }
    
    // uv
    if (hasUV) {
        out.v_uv = in.TEXCOORD_0;
    } else {
        out.v_uv = float2(0.0, 0.0);
    }
    if (needTilingOffset) {
        out.v_uv = out.v_uv * u_tilingOffset.xy + u_tilingOffset.zw;
    }
    
    // color
    if (hasVertexColor) {
        out.v_color = in.COLOR_0;
    }
    
    // normal
    if (hasNormal) {
        if (hasTangent && hasNormalTexture) {
            out.normalW = normalize( float3x3(u_normalMat.columns[0].xyz,
                                              u_normalMat.columns[1].xyz,
                                              u_normalMat.columns[2].xyz) * normal.xyz);
            out.tangentW = normalize( float3x3(u_normalMat.columns[0].xyz,
                                               u_normalMat.columns[1].xyz,
                                               u_normalMat.columns[2].xyz) * tangent.xyz);
            out.bitangentW = -cross( out.normalW, out.tangentW ); // sign is important
        } else {
            out.v_normal = normalize( float3x3(u_normalMat.columns[0].xyz,
                                               u_normalMat.columns[1].xyz,
                                               u_normalMat.columns[2].xyz) * normal);
        }
    }
    
    // world pos
    if (needWorldPos) {
        float4 temp_pos = u_modelMat * position;
        out.v_pos = temp_pos.xyz / temp_pos.w;
    }
    
    if (hasShadow) {
        out.view_pos = (u_MVMat * float4( in.position, 1.0)).xyz;
    }
    
    out.position = u_MVPMat * position;
    return out;
}

// MARK: - Fragment
// MARK: - Common
#define RECIPROCAL_PI 0.31830988618
#define EPSILON 1e-6
#define LOG2 1.442695

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
    float     roughness;
    float3    specularColor;
    float opacity;
} PhysicalMaterial;

float pow2( const float x ) {
    return x * x;
}

float3 BRDF_Diffuse_Lambert( const float3 diffuseColor ) {
    return RECIPROCAL_PI * diffuseColor;
}

float computeSpecularOcclusion( const float dotNV, const float ambientOcclusion, const float roughness ) {
    return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );
}

PhysicalMaterial getPhysicalMaterial(float4 diffuseColor,
                                     float metal,
                                     float roughness,
                                     float3 specularColor,
                                     float glossiness,
                                     float alphaCutoff,
                                     float4 v_color,
                                     float2 v_uv,
                                     texture2d<float> u_baseColorTexture,
                                     texture2d<float> u_metallicRoughnessTexture,
                                     texture2d<float> u_specularGlossinessTexture,
                                     sampler textureSampler){
    PhysicalMaterial material;
    if (hasBaseColorMap) {
        float4 baseColor = u_baseColorTexture.sample(textureSampler, v_uv);
        diffuseColor *= baseColor;
    }
    
    if (hasVertexColor) {
        diffuseColor *= v_color;
    }
    
    if (needAlphaCutoff) {
        if( diffuseColor.a < alphaCutoff ) {
            discard_fragment();
        }
    }
    
    if (hasMetalRoughnessMap) {
        float4 metalRoughMapColor = u_metallicRoughnessTexture.sample(textureSampler, v_uv );
        roughness *= metalRoughMapColor.g;
        metal *= metalRoughMapColor.b;
    }
    
    if (hasSpecularGlossinessMap) {
        float4 specularGlossinessColor = u_specularGlossinessTexture.sample(textureSampler, v_uv);
        specularColor *= specularGlossinessColor.rgb;
        glossiness *= specularGlossinessColor.a;
    }
    
    if (isMetallicWorkFlow) {
        material.diffuseColor = diffuseColor.rgb * ( 1.0 - metal );
        material.specularColor = mix( float3( 0.04), diffuseColor.rgb, metal );
        material.roughness = clamp( roughness, 0.04, 1.0 );
    } else {
        float specularStrength = max( max( specularColor.r, specularColor.g ), specularColor.b );
        material.diffuseColor = diffuseColor.rgb * ( 1.0 - specularStrength );
        material.specularColor = specularColor;
        material.roughness = clamp( 1.0 - glossiness, 0.04, 1.0 );
    }
    
    material.opacity = diffuseColor.a;
    return material;
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
float3 BRDF_Specular_GGX(float3 incidentDirection, const GeometricContext geometry,
                         const float3 specularColor, const float roughness ) {
    
    float alpha = pow2( roughness ); // UE4's roughness
    
    float3 halfDir = normalize( incidentDirection + geometry.viewDir );
    
    float dotNL = saturate( dot( geometry.normal, incidentDirection ) );
    float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
    float dotNH = saturate( dot( geometry.normal, halfDir ) );
    float dotLH = saturate( dot( incidentDirection, halfDir ) );
    
    float3 F = F_Schlick( specularColor, dotLH );
    
    float G = G_GGX_SmithCorrelated( alpha, dotNL, dotNV );
    
    float D = D_GGX( alpha, dotNH );
    
    return F * ( G * D );
    
} // validated

void addDirectRadiance(float3 incidentDirection, float3 color,
                       GeometricContext geometry, PhysicalMaterial material,
                       thread ReflectedLight& reflectedLight) {
    float dotNL = saturate( dot( geometry.normal, incidentDirection ) );
    
    float3 irradiance = dotNL * color;
    irradiance *= M_PI_F;
    
    reflectedLight.directSpecular += irradiance * BRDF_Specular_GGX( incidentDirection, geometry,
                                                                    material.specularColor, material.roughness);
    
    reflectedLight.directDiffuse += irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );
}

void addDirectionalDirectLightRadiance(DirectLightData directionalLight, GeometricContext geometry,
                                       PhysicalMaterial material, thread ReflectedLight& reflectedLight) {
    float3 color = directionalLight.color;
    float3 direction = -directionalLight.direction;
    
    addDirectRadiance( direction, color, geometry, material, reflectedLight );
}

void addPointDirectLightRadiance(PointLightData pointLight, GeometricContext geometry,
                                 PhysicalMaterial material, thread ReflectedLight& reflectedLight) {
    
    float3 lVector = pointLight.position - geometry.position;
    float3 direction = normalize( lVector );
    
    float lightDistance = length( lVector );
    
    float3 color = pointLight.color;
    color *= clamp(1.0 - pow(lightDistance/pointLight.distance, 4.0), 0.0, 1.0);
    
    addDirectRadiance( direction, color, geometry, material, reflectedLight );
}

void addSpotDirectLightRadiance(SpotLightData spotLight, GeometricContext geometry,
                                PhysicalMaterial material, thread ReflectedLight& reflectedLight) {
    
    float3 lVector = spotLight.position - geometry.position;
    float3 direction = normalize( lVector );
    
    float lightDistance = length( lVector );
    float angleCos = dot( direction, -spotLight.direction );
    
    float spotEffect = smoothstep( spotLight.penumbraCos, spotLight.angleCos, angleCos );
    float decayEffect = clamp(1.0 - pow(lightDistance/spotLight.distance, 4.0), 0.0, 1.0);
    
    float3 color = spotLight.color;
    color *= spotEffect * decayEffect;
    
    addDirectRadiance( direction, color, geometry, material, reflectedLight );
}

void addTotalDirectRadiance(GeometricContext geometry, PhysicalMaterial material,
                            thread ReflectedLight& reflectedLight,
                            device DirectLightData *u_directLight [[buffer(10), function_constant(hasDirectLight)]],
                            device PointLightData *u_pointLight [[buffer(11), function_constant(hasPointLight)]],
                            device SpotLightData *u_spotLight [[buffer(12), function_constant(hasSpotLight)]]){
    if (directLightCount) {
        for ( int i = 0; i < directLightCount; i ++ ) {
            addDirectionalDirectLightRadiance( u_directLight[i], geometry, material, reflectedLight );
        }
    }
    
    if (pointLightCount) {
        for ( int i = 0; i < pointLightCount; i ++ ) {
            addPointDirectLightRadiance( u_pointLight[i], geometry, material, reflectedLight );
        }
    }
    
    if (spotLightCount) {
        for ( int i = 0; i < spotLightCount; i ++ ) {
            addSpotDirectLightRadiance( u_spotLight[i], geometry, material, reflectedLight );
        }
    }
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

// ------------------------Specular------------------------

// ref: https://www.unrealengine.com/blog/physically-based-shading-on-mobile - environmentBRDF for GGX on mobile
float3 envBRDFApprox(float3 specularColor,float roughness, float dotNV ) {
    const float4 c0 = float4( - 1, - 0.0275, - 0.572, 0.022 );
    
    const float4 c1 = float4( 1, 0.0425, 1.04, - 0.04 );
    
    float4 r = roughness * c0 + c1;
    
    float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;
    
    float2 AB = float2( -1.04, 1.04 ) * a004 + r.zw;
    
    return specularColor * AB.x + AB.y;
}


float getSpecularMIPLevel(float roughness, int maxMIPLevel ) {
    return roughness * float(maxMIPLevel);
}

float3 getLightProbeRadiance(const GeometricContext geometry, float roughness, int maxMIPLevel, float specularIntensity,
                             texturecube<float> u_env_specularTexture, sampler textureSampler ) {
    if (hasSpecularEnv) {
        float3 reflectVec = reflect( -geometry.viewDir, geometry.normal );
        float specularMIPLevel = getSpecularMIPLevel(roughness, maxMIPLevel );
        
        float4 envMapColor = u_env_specularTexture.sample(textureSampler, reflectVec, level(specularMIPLevel));
        
        return envMapColor.rgb * specularIntensity;
    } else {
        return float3(0.0);
    }
}

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
            tbn = matrix_float3x3(in.tangentW, in.bitangentW, in.normalW);
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
                             device DirectLightData *u_directLight [[buffer(8), function_constant(hasDirectLight)]],
                             device PointLightData *u_pointLight [[buffer(9), function_constant(hasPointLight)]],
                             device SpotLightData *u_spotLight [[buffer(10), function_constant(hasSpotLight)]],
                             constant ShadowData* u_shadowData [[buffer(11), function_constant(hasShadow)]],
                             depth2d_array<float> u_shadowMap [[texture(0), function_constant(hasShadow)]],
                             // pbr_envmap_light_frag_define
                             constant EnvMapLight &u_envMapLight [[buffer(12)]],
                             constant float3 *u_env_sh [[buffer(13), function_constant(hasSH)]],
                             texturecube<float> u_env_specularTexture [[texture(1), function_constant(hasSpecularEnv)]],
                             texturecube<float> u_env_diffuseTexture [[texture(2), function_constant(hasDiffuseEnv)]],
                             texture2d<float> samplerBRDFLUT [[texture(3)]],
                             //pbr base frag define
                             constant float &u_alphaCutoff [[buffer(14)]],
                             constant float4 &u_baseColor [[buffer(15)]],
                             constant float &u_metal [[buffer(16)]],
                             constant float &u_roughness [[buffer(17)]],
                             constant float3 &u_specularColor [[buffer(18)]],
                             constant float &u_glossiness [[buffer(19)]],
                             constant float3 &u_emissiveColor [[buffer(20)]],
                             constant float &u_normalIntensity [[buffer(21)]],
                             constant float &u_occlusionStrength [[buffer(22)]],
                             // pbr_texture_frag_define
                             texture2d<float> u_baseColorTexture [[texture(4), function_constant(hasBaseColorMap)]],
                             texture2d<float> u_normalTexture [[texture(5), function_constant(hasNormalTexture)]],
                             texture2d<float> u_emissiveTexture [[texture(6), function_constant(hasEmissiveMap)]],
                             texture2d<float> u_metallicRoughnessTexture [[texture(7), function_constant(hasMetalRoughnessMap)]],
                             texture2d<float> u_specularGlossinessTexture [[texture(8), function_constant(hasSpecularGlossinessMap)]],
                             texture2d<float> u_occlusionTexture [[texture(9), function_constant(hasOcclusionMap)]],
                             bool is_front_face [[front_facing]]) {
    GeometricContext geometry;
    geometry.position = in.v_pos;
    geometry.normal = getPbrNormal(in, u_normalIntensity, textureSampler, u_normalTexture, is_front_face);
    geometry.viewDir = normalize(u_cameraPos - in.v_pos);
    
    PhysicalMaterial material = getPhysicalMaterial(u_baseColor, u_metal, u_roughness, u_specularColor, u_glossiness, u_alphaCutoff,
                                                    in.v_color, in.v_uv,
                                                    u_baseColorTexture, u_metallicRoughnessTexture, u_specularGlossinessTexture, textureSampler);
    ReflectedLight reflectedLight = ReflectedLight{ float3( 0 ), float3( 0 ), float3( 0 ), float3( 0 ) };
    float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
    
    // Direct Light
    addTotalDirectRadiance(geometry, material, reflectedLight,
                           u_directLight, u_pointLight, u_spotLight);
    // IBL diffuse
    float3 irradiance;
    if (hasSH) {
        irradiance = getLightProbeIrradiance(u_env_sh, geometry.normal) * u_envMapLight.diffuseIntensity;
    } else if (hasDiffuseEnv) {
        irradiance = u_env_diffuseTexture.sample(textureSampler, geometry.normal).rgb * u_envMapLight.diffuseIntensity;
    } else {
        irradiance = u_envMapLight.diffuse * M_PI_F * u_envMapLight.diffuseIntensity;
    }
    reflectedLight.indirectDiffuse += irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );
    
    // IBL specular
    float3 radiance = getLightProbeRadiance( geometry, material.roughness, int(u_envMapLight.mipMapLevel), u_envMapLight.specularIntensity,
                                            u_env_specularTexture, textureSampler);
    reflectedLight.indirectSpecular += radiance * envBRDFApprox(material.specularColor, material.roughness, dotNV );
    
    // Occlusion
    if (hasOcclusionMap) {
        float ambientOcclusion = (u_occlusionTexture.sample(textureSampler, in.v_uv).r - 1.0) * u_occlusionStrength + 1.0;
        reflectedLight.indirectDiffuse *= ambientOcclusion;
        
        if (hasSpecularEnv) {
            reflectedLight.indirectSpecular *= computeSpecularOcclusion(ambientOcclusion, material.roughness, dotNV);
        }
    }
    
    // Emissive
    float3 emissiveRadiance = u_emissiveColor;
    if (hasEmissiveMap) {
        float4 emissiveMapColor = u_emissiveTexture.sample(textureSampler, in.v_uv);
        emissiveRadiance = emissiveMapColor.rgb;
    }

    if (hasShadow) {
        float shadow = 0;
        for( int i = 0; i < shadowMapCount; i++) {
            shadow += filterPCF(in.v_pos, in.view_pos, u_shadowMap, u_shadowData, i);
//            shadow += textureProj(in.v_pos, in.view_pos, float2(0), u_shadowMap, u_shadowData, i);
        }
        shadow /= shadowMapCount;
        
        reflectedLight.directDiffuse *= shadow;
        reflectedLight.indirectDiffuse *= shadow;
    }
    
    float3 totalRadiance = reflectedLight.directDiffuse +
    reflectedLight.indirectDiffuse +
    reflectedLight.directSpecular +
    reflectedLight.indirectSpecular +
    emissiveRadiance;
    
    float4 targetColor =float4(totalRadiance, material.opacity);    
    return targetColor;
}
