//
//  skybox.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/23.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.metal"

typedef struct {
    float3 position [[attribute(Position)]];
} VertexIn;

typedef struct {
    float4 position [[position]];
    float3 v_cubeUV;
} VertexOut;

vertex VertexOut vertex_skybox(const VertexIn in [[stage_in]],
                               constant matrix_float4x4 &u_mvpNoscale [[buffer(10)]]) {
    VertexOut out;
    
    out.v_cubeUV = in.position.xyz;
    out.position = (u_mvpNoscale * float4( in.position, 1.0 )).xyww;
    return out;
}

fragment float4 fragment_skybox(VertexOut in [[stage_in]],
                                sampler textureSampler [[sampler(0)]],
                                texturecube<float> u_skybox [[texture(0)]]) {
    return u_skybox.sample(textureSampler, in.v_cubeUV);
}
