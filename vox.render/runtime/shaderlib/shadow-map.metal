//
//  shadow-map.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/23.
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
    float3 normalW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 tangentW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 bitangentW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 v_normal [[function_constant(hasNormalNotHasTangentOrHasNormalTexture)]];
} VertexOut;

vertex VertexOut vertex_shadow_map(const VertexIn in [[stage_in]],
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
    
    //MARK: - begin_position_vert
    float4 position = float4( in.position, 1.0);
    
    //MARK: - begin_normal_vert
    float3 normal;
    float4 tangent;
    if (hasNormal) {
        normal = in.NORMAL;
        if (hasTangent && hasNormalTexture) {
            tangent = in.TANGENT;
        }
    }
    
    //MARK: - blendShape_vert
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
    
    //MARK: - skinning_vert
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
    
    //MARK: - shadow_vert position_vert
    if (needGenerateShadowMap) {
        out.position = u_projMatFromLight * u_viewMatFromLight * u_modelMat * position;
    } else {
        out.position = u_MVPMat * position;
    }
    
    return out;
}

//MARK: - fragment_shadow_map
float4 pack (float depth) {
    // Use rgba 4 bytes with a total of 32 bits to store the z value, and the accuracy of 1 byte is 1/256.
    const float4 bitShift = float4(1.0, 256.0, 256.0 * 256.0, 256.0 * 256.0 * 256.0);
    const float4 bitMask = float4(1.0/256.0, 1.0/256.0, 1.0/256.0, 0.0);
    
    float4 rgbaDepth = fract(depth * bitShift); // Calculate the z value of each point
    
    // Cut off the value which do not fit in 8 bits
    rgbaDepth -= rgbaDepth.gbaa * bitMask;
    
    return rgbaDepth;
}

fragment float4 fragment_shadow_map(VertexOut in [[stage_in]]) {
    // Store the z value separately in the rgba component, and the shadow color is also the depth value z
    return pack(in.position.z);
}

//MARK: - fragment_shadow
constant float4 bitShift = float4(1.0, 1.0/256.0, 1.0/(256.0*256.0), 1.0/(256.0*256.0*256.0));

/// Unpack depth value.
float unpack(const float4 rgbaDepth) {
    return dot(rgbaDepth, bitShift);
}

/// Degree of shadow.
float getVisibility(float4 positionFromLight, int index,
                    const texture2d_array<float> shadowMap, sampler textureSampler, float2 mapSize,
                    float intensity, float bias, float radius) {
    
    float3 shadowCoord = (positionFromLight.xyz/positionFromLight.w)/2.0 + 0.5;
    float filterX = step(0.0, shadowCoord.x) * (1.0 - step(1.0, shadowCoord.x));
    float filterY = step(0.0, shadowCoord.y) * (1.0 - step(1.0, shadowCoord.y));
    
    shadowCoord.z -= bias;
    float2 texelSize = float2( 1.0 ) / mapSize;
    
    float visibility = 0.0;
    for (float y = -1.0 ; y <=1.0 ; y+=1.0) {
        for (float x = -1.0 ; x <=1.0 ; x+=1.0) {
            float2 uv = shadowCoord.xy + texelSize * float2(x, y) * radius;
            float4 rgbaDepth = shadowMap.sample(textureSampler, uv, index);
            float depth = unpack(rgbaDepth);
            visibility += step(depth, shadowCoord.z) * intensity;
        }
    }
    
    visibility *= ( 1.0 / 9.0 );
    return visibility * filterX * filterY;
    
}

fragment float4 fragment_shadow(VertexOut in [[stage_in]],
                                constant float *u_shadowBias [[buffer(0), function_constant(shadowMapCount)]],
                                constant float *u_shadowIntensity [[buffer(1), function_constant(shadowMapCount)]],
                                constant float *u_shadowRadius [[buffer(2), function_constant(shadowMapCount)]],
                                constant float2 *u_shadowMapSize [[buffer(3), function_constant(shadowMapCount)]],
                                texture2d_array<float> u_shadowMaps [[texture(0), function_constant(shadowMapCount)]],
                                sampler textureSampler [[sampler(0), function_constant(shadowMapCount)]]) {
    float4 shadowColor = float4(1.0, 1.0, 1.0, 1.0);
    if (shadowMapCount) {
        float visibility = 1.0;

        visibility = clamp(visibility, 0.0, 1.0);
        shadowColor = float4(visibility, visibility, visibility, 1.0);
    }
    
    // Store the z value separately in the rgba component, and the shadow color is also the depth value z
    return pack(in.position.z);
}
