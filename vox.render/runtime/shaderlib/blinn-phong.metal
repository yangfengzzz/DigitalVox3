//
//  blinn-phong.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/20.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.metal"

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
} VertexOut;

vertex VertexOut vertex_blinn_phong(const VertexIn in [[stage_in]],
                                    constant matrix_float4x4 &u_localMat [[buffer(0)]],
                                    constant matrix_float4x4 &u_modelMat [[buffer(1)]],
                                    constant matrix_float4x4 &u_viewMat [[buffer(2)]],
                                    constant matrix_float4x4 &u_projMat [[buffer(3)]],
                                    constant matrix_float4x4 &u_MVMat [[buffer(4)]],
                                    constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                                    constant matrix_float4x4 &u_normalMat [[buffer(6)]],
                                    constant float3 &u_cameraPos [[buffer(7)]],
                                    constant float4 &u_tilingOffset [[buffer(8)]],
                                    constant matrix_float4x4 &u_viewMatFromLight [[buffer(9)]],
                                    constant matrix_float4x4 &u_projMatFromLight [[buffer(10)]],
                                    sampler u_jointSampler [[sampler(0), function_constant(hasSkinAndHasJointTexture)]],
                                    texture2d<float> u_jointTexture [[texture(0), function_constant(hasSkinAndHasJointTexture)]],
                                    constant int &u_jointCount [[buffer(11), function_constant(hasSkinAndHasJointTexture)]],
                                    constant matrix_float4x4 *u_jointMatrix [[buffer(12), function_constant(hasSkinNotHasJointTexture)]],
                                    constant float *u_blendShapeWeights [[buffer(13), function_constant(hasBlendShape)]]) {
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
            out.normalW = normalize( float3x3(u_MVMat.columns[0].xyz,
                                              u_MVMat.columns[1].xyz,
                                              u_MVMat.columns[2].xyz) * normal.xyz);
            out.tangentW = normalize( float3x3(u_normalMat.columns[0].xyz,
                                               u_normalMat.columns[1].xyz,
                                               u_normalMat.columns[2].xyz) * tangent.xyz);
            out.bitangentW = cross( out.normalW, out.tangentW ) * tangent.w;
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
    
    // shadow && position
    if (needGenerateShadowMap) {
        out.position = u_projMatFromLight * u_viewMatFromLight * u_modelMat * position;
    } else {
        out.position = u_MVPMat * position;
    }
    
    return out;
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

float3 getNormal(VertexOut in, float u_normalIntensity,
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

fragment float4 fragment_blinn_phong(VertexOut in [[stage_in]],
                                     sampler textureSampler [[sampler(0)]],
                                     constant matrix_float4x4 &u_localMat [[buffer(0)]],
                                     constant matrix_float4x4 &u_modelMat [[buffer(1)]],
                                     constant matrix_float4x4 &u_viewMat [[buffer(2)]],
                                     constant matrix_float4x4 &u_projMat [[buffer(3)]],
                                     constant matrix_float4x4 &u_MVMat [[buffer(4)]],
                                     constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                                     constant matrix_float4x4 &u_normalMat [[buffer(6)]],
                                     constant float3 &u_cameraPos [[buffer(7)]],
                                     constant EnvMapLight &u_envMapLight [[buffer(8)]],
                                     constant float3 *u_env_sh [[buffer(9), function_constant(hasSH)]],
                                     texturecube<float> u_env_specularTexture [[texture(0), function_constant(hasSpecularEnv)]],
                                     constant float3 *u_directLightColor [[buffer(10), function_constant(hasDirectLight)]],
                                     constant float3 *u_directLightDirection [[buffer(11), function_constant(hasDirectLight)]],
                                     constant float3 *u_pointLightColor [[buffer(12), function_constant(hasPointLight)]],
                                     constant float3 *u_pointLightPosition [[buffer(13), function_constant(hasPointLight)]],
                                     constant float *u_pointLightDistance [[buffer(14), function_constant(hasPointLight)]],
                                     constant float3 *u_spotLightColor [[buffer(15), function_constant(hasSpotLight)]],
                                     constant float3 *u_spotLightPosition [[buffer(16), function_constant(hasSpotLight)]],
                                     constant float3 *u_spotLightDirection [[buffer(17), function_constant(hasSpotLight)]],
                                     constant float *u_spotLightDistance [[buffer(18), function_constant(hasSpotLight)]],
                                     constant float *u_spotLightAngleCos [[buffer(19), function_constant(hasSpotLight)]],
                                     constant float *u_spotLightPenumbraCos [[buffer(20), function_constant(hasSpotLight)]],
                                     constant float4 &u_emissiveColor [[buffer(21)]],
                                     constant float4 &u_diffuseColor [[buffer(22)]],
                                     constant float4 &u_specularColor [[buffer(23)]],
                                     constant float &u_shininess [[buffer(24)]],
                                     constant float &u_normalIntensity [[buffer(25)]],
                                     constant float &u_alphaCutoff [[buffer(26)]],
                                     texture2d<float> u_emissiveTexture [[texture(1), function_constant(hasEmissiveTexture)]],
                                     texture2d<float> u_diffuseTexture [[texture(2), function_constant(hasDiffuseTexture)]],
                                     texture2d<float> u_specularTexture [[texture(3), function_constant(hasSpecularTexture)]],
                                     texture2d<float> u_normalTexture [[texture(4), function_constant(hasNormalTexture)]],
                                     bool is_front_face [[front_facing]]) {
    float4 ambient = float4(0.0);
    float4 emission = u_emissiveColor;
    float4 diffuse = u_diffuseColor;
    float4 specular = u_specularColor;
    if (hasEmissiveTexture) {
        emission = u_emissiveTexture.sample(textureSampler, in.v_uv);
    }
    if (hasDiffuseTexture) {
        diffuse *= u_diffuseTexture.sample(textureSampler, in.v_uv);
    }
    if (hasVertexColor) {
        diffuse *= in.v_color;
    }
    if (hasSpecularTexture) {
        specular *= u_specularTexture.sample(textureSampler, in.v_uv);
    }
    ambient = float4(u_envMapLight.diffuse * u_envMapLight.diffuseIntensity, 1.0) * diffuse;
    
    float3 V;
    if (needWorldPos) {
        V =  normalize( u_cameraPos - in.v_pos );
    }
    
    float3 N = getNormal(in, u_normalIntensity, textureSampler, u_normalTexture, is_front_face);
    float3 lightDiffuse = float3( 0.0, 0.0, 0.0 );
    float3 lightSpecular = float3( 0.0, 0.0, 0.0 );
    if (hasDirectLight) {
        DirectLight directionalLight;
        
        for( int i = 0; i < directLightCount; i++ ) {
            directionalLight.color = u_directLightColor[i];
            directionalLight.direction = u_directLightDirection[i];
            
            float d = max(dot(N, -directionalLight.direction), 0.0);
            lightDiffuse += directionalLight.color * d;
            
            float3 halfDir = normalize( V - directionalLight.direction );
            float s = pow( clamp( dot( N, halfDir ), 0.0, 1.0 ), u_shininess );
            lightSpecular += directionalLight.color * s;
        }
    }
    if (hasPointLight) {
        PointLight pointLight;
        
        for( int i = 0; i < pointLightCount; i++ ) {
            pointLight.color = u_pointLightColor[i];
            pointLight.position = u_pointLightPosition[i];
            pointLight.distance = u_pointLightDistance[i];
            
            float3 direction = in.v_pos - pointLight.position;
            float dist = length( direction );
            direction /= dist;
            float decay = clamp(1.0 - pow(dist / pointLight.distance, 4.0), 0.0, 1.0);
            
            float d =  max( dot( N, -direction ), 0.0 ) * decay;
            lightDiffuse += pointLight.color * d;
            
            float3 halfDir = normalize( V - direction );
            float s = pow( clamp( dot( N, halfDir ), 0.0, 1.0 ), u_shininess )  * decay;
            lightSpecular += pointLight.color * s;
        }
    }
    if (hasSpotLight) {
        SpotLight spotLight;
        
        for( int i = 0; i < spotLightCount; i++) {
            spotLight.color = u_spotLightColor[i];
            spotLight.position = u_spotLightPosition[i];
            spotLight.direction = u_spotLightDirection[i];
            spotLight.distance = u_spotLightDistance[i];
            spotLight.angleCos = u_spotLightAngleCos[i];
            spotLight.penumbraCos = u_spotLightPenumbraCos[i];
            
            float3 direction = spotLight.position - in.v_pos;
            float lightDistance = length( direction );
            direction /= lightDistance;
            float angleCos = dot( direction, -spotLight.direction );
            float decay = clamp(1.0 - pow(lightDistance/spotLight.distance, 4.0), 0.0, 1.0);
            float spotEffect = smoothstep( spotLight.penumbraCos, spotLight.angleCos, angleCos );
            float decayTotal = decay * spotEffect;
            float d = max( dot( N, direction ), 0.0 )  * decayTotal;
            lightDiffuse += spotLight.color * d;
            
            float3 halfDir = normalize( V + direction );
            float s = pow( clamp( dot( N, halfDir ), 0.0, 1.0 ), u_shininess ) * decayTotal;
            lightSpecular += spotLight.color * s;
        }
    }
    
    diffuse *= float4( lightDiffuse, 1.0 );
    specular *= float4( lightSpecular, 1.0 );
    if (needAlphaCutoff) {
        if( diffuse.a < u_alphaCutoff ) {
            discard_fragment();
        }
    }
    
    float4 final_color = emission + ambient + diffuse + specular;
    final_color.a = diffuse.a;
    return final_color;
}
