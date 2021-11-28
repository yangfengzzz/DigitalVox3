//
//  unlit.metal
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
    float2 v_uv;
} VertexOut;

vertex VertexOut vertex_unlit(const VertexIn in [[stage_in]],
                              constant matrix_float4x4 &u_MVPMat [[buffer(0)]],
                              constant float4 &u_tilingOffset [[buffer(8)]],
                              sampler u_jointSampler [[sampler(0), function_constant(hasSkinAndHasJointTexture)]],
                              texture2d<float> u_jointTexture [[texture(0), function_constant(hasSkinAndHasJointTexture)]],
                              constant int &u_jointCount [[buffer(11), function_constant(hasSkinAndHasJointTexture)]],
                              constant matrix_float4x4 *u_jointMatrix [[buffer(12), function_constant(hasSkinNotHasJointTexture)]],
                              constant float *u_blendShapeWeights [[buffer(13), function_constant(hasBlendShape)]]) {
    VertexOut out;
    
    // begin position
    float4 position = float4( in.position, 1.0);
    
    //blendshape
    if (hasBlendShape) {
        position.xyz += in.POSITION_BS0 * u_blendShapeWeights[0];
        position.xyz += in.POSITION_BS1 * u_blendShapeWeights[1];
        position.xyz += in.POSITION_BS2 * u_blendShapeWeights[2];
        position.xyz += in.POSITION_BS3 * u_blendShapeWeights[3];
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
    
    out.position = u_MVPMat * position;
    
    return out;
}

fragment float4 fragment_unlit(VertexOut in [[stage_in]],
                               sampler textureSampler [[sampler(0)]],
                               constant float4 &u_baseColor [[buffer(0)]],
                               constant float &u_alphaCutoff [[buffer(1)]],
                               texture2d<float> u_baseTexture [[texture(0), function_constant(hasBaseTexture)]]) {
    float4 baseColor = u_baseColor;
    
    if (hasBaseTexture) {
        baseColor *= u_baseTexture.sample(textureSampler, in.v_uv);
    }
    
    if (needAlphaCutoff) {
        if( baseColor.a < u_alphaCutoff ) {
            discard_fragment();
        }
    }
    
    return baseColor;
}


