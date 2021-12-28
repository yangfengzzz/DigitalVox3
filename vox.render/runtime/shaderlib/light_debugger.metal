//
//  light_debugger.metal
//  vox.render
//
//  Created by 杨丰 on 2021/12/28.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.h"

struct FairyInOut {
    float4 position [[position]];
    float3 color;
    float2 tex_coord;
};

vertex FairyInOut fairy_vertex(constant vector_float2 *vertices [[ buffer(0) ]],
                               constant matrix_float4x4 &u_viewMat [[buffer(3)]],
                               constant matrix_float4x4 &u_projMat [[buffer(4)]],
                               const device PointLightData *u_pointLight [[ buffer(11) ]],
                               uint iid [[ instance_id ]],
                               uint vid [[ vertex_id ]]) {
    float fairy_size = 0.2;
    
    FairyInOut out;
    
    float3 vertex_position = float3(vertices[vid].xy,0);
    
    float4 viewPos = u_viewMat * float4(u_pointLight[iid].position, 1.0);
    
    float4 vertex_eye_position = float4(fairy_size * vertex_position + viewPos.xyz, 1);
    
    out.position = u_projMat * vertex_eye_position;
    
    // Pass fairy color through
    out.color = u_pointLight[iid].color;
    
    // Convert model position which ranges from [-1, 1] to texture coordinates which ranges
    // from [0-1]
    out.tex_coord = 0.5 * (float2(vertices[vid].xy) + 1);
    
    return out;
}

fragment float4 fairy_fragment(FairyInOut in [[ stage_in ]],
                               texture2d<float> colorMap [[ texture(0) ]]) {
    constexpr sampler linearSampler(mip_filter::linear,
                                    mag_filter::linear,
                                    min_filter::linear);
    
    float4 c = colorMap.sample(linearSampler, float2(in.tex_coord));
    
    float3 fragColor = in.color * c.x;
    
    return float4(fragColor, c.x);
}

