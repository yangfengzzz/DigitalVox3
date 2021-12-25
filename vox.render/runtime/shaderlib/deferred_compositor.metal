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

fragment half4
deferred_directional_lighting_fragment_traditional(QuadInOut in [[ stage_in ]],
                                                   texture2d<half> albedo_specular_GBuffer [[ texture(0) ]],
                                                   texture2d<half> normal_shadow_GBuffer [[ texture(1) ]]) {
    uint2 position = uint2(in.position.xy);
    half4 normal_shadow = normal_shadow_GBuffer.read(position.xy);
    half4 albedo_specular = albedo_specular_GBuffer.read(position.xy);
    return albedo_specular;
}
