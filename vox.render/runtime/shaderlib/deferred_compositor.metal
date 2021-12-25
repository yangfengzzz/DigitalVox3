//
//  deferred_compositor.metal
//  vox.render
//
//  Created by 杨丰 on 2021/12/25.
//

#include <metal_stdlib>
using namespace metal;

struct QuadInOut {
    float4 position [[position]];
#if USE_EYE_DEPTH
    float3 eye_position;
#endif
};

constant vector_float2 vertices[] = {
    { -1.0f,  -1.0f, },
    { -1.0f,   1.0f, },
    {  1.0f,  -1.0f, },
    
    {  1.0f,  -1.0f, },
    { -1.0f,   1.0f, },
    {  1.0f,   1.0f, },
};

vertex QuadInOut
deferred_direction_lighting_vertex(uint vid[[ vertex_id ]]) {
    QuadInOut out;
    
    out.position = float4(vertices[vid], 0, 1);
    
#if USE_EYE_DEPTH
    float4 unprojected_eye_coord = frameData.projection_matrix_inverse * out.position;
    out.eye_position = unprojected_eye_coord.xyz / unprojected_eye_coord.w;
#endif
    
    return out;
}

fragment float4
deferred_directional_lighting_fragment_traditional(QuadInOut in [[ stage_in ]],
                                                   texture2d<float> diffuse_occlusion_GBuffer [[texture(0)]],
                                                   texture2d<float> specular_roughness_GBuffer [[texture(1)]],
                                                   texture2d<float> normal_GBuffer [[texture(2)]],
                                                   texture2d<float> emissive_GBuffer [[texture(3)]]) {
    uint2 position = uint2(in.position.xy);
    float4 diffuse_occlusion = diffuse_occlusion_GBuffer.read(position.xy);
    float4 specular_roughness = specular_roughness_GBuffer.read(position.xy);
    return diffuse_occlusion;
}
