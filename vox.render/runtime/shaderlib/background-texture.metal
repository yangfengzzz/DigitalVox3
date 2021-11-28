//
//  background-texture.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/23.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.metal"

typedef struct {
    float3 position [[attribute(Position)]];
    float2 TEXCOORD_0 [[attribute(UV_0)]];
} VertexIn;

typedef struct {
    float4 position [[position]];
    float2 v_uv;
} VertexOut;

vertex VertexOut vertex_background_texture(const VertexIn vertexIn [[stage_in]]) {
    VertexOut out;
    out.position = float4(vertexIn.position, 1.0);
    out.v_uv = vertexIn.TEXCOORD_0;
    return out;
}

fragment float4 fragment_background_texture(VertexOut in [[stage_in]],
                                            sampler textureSampler [[sampler(0)]],
                                            texture2d<float> u_baseTexture [[texture(0)]]) {
    return u_baseTexture.sample(textureSampler, in.v_uv);
}
