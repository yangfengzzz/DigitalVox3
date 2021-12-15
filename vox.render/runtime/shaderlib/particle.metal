//
//  particle.metal
//  vox.render
//
//  Created by 杨丰 on 2021/12/14.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

typedef struct {
    float3 a_position [[attribute(0)]];
    float4 a_color [[attribute(1)]];
} VertexIn;

typedef struct {
    float4 position [[position]];
    float4 v_color;
    float pointSize [[point_size]];
} VertexOut;

vertex VertexOut vertex_particle(const VertexIn vertexIn [[stage_in]],
                                 constant matrix_float4x4 &u_VPMat [[buffer(12)]]) {
    VertexOut out;

    out.position = u_VPMat * float4(vertexIn.a_position, 1.0);
    out.pointSize = 15;
    out.v_color = vertexIn.a_color;
    
    return out;
}

fragment float4 fragment_particle(VertexOut in [[stage_in]],
                                  sampler textureSampler [[sampler(0)]],
                                  texture2d<float> u_particleTexture [[texture(0)]],
                                  float2 point [[point_coord]]) {
    if (length(point - float2(0.5)) > 0.5) {
        discard_fragment();
    }
    
    constexpr sampler default_sampler;
    float4 color = u_particleTexture.sample(default_sampler, point);
    color *= in.v_color;
    color.a = 0.4;
    return color;
}

