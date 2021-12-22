//
//  shadow_debugger.metal
//  vox.render
//
//  Created by 杨丰 on 2021/12/21.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.h"

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
    float3 view_pos;
} VertexOut;

vertex VertexOut vertex_shadow_debugger(const VertexIn in [[stage_in]],
                                        constant matrix_float4x4 &u_MVPMat [[buffer(7)]],
                                        constant matrix_float4x4 &u_MVMat [[buffer(8)]]) {
    VertexOut out;
    
    out.v_uv = in.TEXCOORD_0;
    out.position = u_MVPMat * float4( in.position, 1.0);
    out.view_pos = (u_MVMat * float4( in.position, 1.0)).xyz;
    return out;
}

float LinearizeDepth(float depth) {
    float n = 1.0; // camera z near
    float f = 128.0; // camera z far
    float z = depth;
    return (2.0 * n) / (f + n - z * (f - n));
}

fragment float4 fragment_shadow_debugger(VertexOut in [[stage_in]],
                                         sampler textureSampler [[sampler(0)]],
                                         texture2d_array<float> u_shadowMap [[texture(0)]]) {
    float depth = u_shadowMap.sample(textureSampler, in.v_uv, 0).r;
    return float4(float3(1.0-LinearizeDepth(depth)), 1.0);
}

fragment float4 fragment_cascade_shadow_debugger(VertexOut in [[stage_in]],
                                                 sampler textureSampler [[sampler(0)]],
                                                 constant ShadowData* u_shadowData [[buffer(27), function_constant(hasShadow)]],
                                                 depth2d_array<float> u_shadowMap [[texture(5), function_constant(hasShadow)]]) {
    // Get cascade index for the current fragment's view position
    uint cascadeIndex = 0;
    for(uint i = 0; i < 4 - 1; ++i) {
        if(in.view_pos.z < u_shadowData[0].cascadeSplits[i]) {
            cascadeIndex = i + 1;
        }
    }
    
    
    float depth = u_shadowMap.sample(textureSampler, in.v_uv, 0);
    
    if (cascadeIndex == 0) {
        return float4(1,1,1,1);
    } else if (cascadeIndex == 1) {
        return float4(1,0,0,1);
    } else if (cascadeIndex == 2) {
        return float4(0,1,0,1);
    } else if (cascadeIndex == 3) {
        return float4(0,0,1,1);
    } else {
        return float4(float3(1.0-LinearizeDepth(depth)), 1.0);
    }
}
