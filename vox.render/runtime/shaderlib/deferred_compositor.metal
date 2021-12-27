//
//  deferred_compositor.metal
//  vox.render
//
//  Created by 杨丰 on 2021/12/25.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.h"

struct QuadInOut {
    float4 position [[position]];
    float3 eye_position;
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
deferred_direction_lighting_vertex(uint vid[[ vertex_id ]],
                                   constant matrix_float4x4 &u_projInvMat [[buffer(10)]]) {
    QuadInOut out;
    
    out.position = float4(vertices[vid], 0, 1);
    float4 unprojected_eye_coord = u_projInvMat * out.position;
    out.eye_position = unprojected_eye_coord.xyz / unprojected_eye_coord.w;
    
    return out;
}

fragment float4
deferred_directional_lighting_fragment_traditional(QuadInOut in [[ stage_in ]],
                                                   texture2d<float> diffuse_occlusion_GBuffer [[texture(0)]],
                                                   texture2d<float> specular_roughness_GBuffer [[texture(1)]],
                                                   texture2d<float> normal_GBuffer [[texture(2)]],
                                                   texture2d<float> emissive_GBuffer [[texture(3)]],
                                                   depth2d<float> depth_GBuffer [[texture(4)]],
                                                   constant float &u_shininess [[buffer(18)]],
                                                   device DirectLightData *u_directLight [[buffer(2), function_constant(hasDirectLight)]]) {
    uint2 position = uint2(in.position.xy);
    float4 diffuse_occlusion = diffuse_occlusion_GBuffer.read(position.xy);
    float4 specular_roughness = specular_roughness_GBuffer.read(position.xy);
    float3 normal = normal_GBuffer.read(position.xy).xyz;
    float depth = depth_GBuffer.read(position.xy);
    
    float3 lightDiffuse = float3( 0.0, 0.0, 0.0 );
    float3 lightSpecular = float3( 0.0, 0.0, 0.0 );
    if (hasDirectLight) {
        for( int i = 0; i < directLightCount; i++ ) {
            float d = max(dot(normal, -u_directLight[i].direction), 0.0);
            lightDiffuse += u_directLight[i].color * d;
            
            // Used eye_space depth to determine the position of the fragment in eye_space
            float3 eye_space_fragment_pos = normalize(in.eye_position) * depth;
            float3 halfway_vector = normalize( eye_space_fragment_pos - u_directLight[i].direction );
            float s = pow( clamp( dot( normal, halfway_vector ), 0.0, 1.0 ), u_shininess );
            lightSpecular += u_directLight[i].color * s;
        }
    }
    
    float3 diffuse = diffuse_occlusion.xyz * lightDiffuse;
    float3 specular = specular_roughness.xyz * lightSpecular;
    
    return float4(diffuse + specular, 1.0);
}
