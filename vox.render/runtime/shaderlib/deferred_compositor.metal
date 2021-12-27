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
                                                   device DirectLightData *u_directLight [[buffer(2), function_constant(hasDirectLight)]]) {
    float u_shininess = 1.0; // rely on material which can't be get
    
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
    float3 specular = specular_roughness.x * lightSpecular * diffuse_occlusion.xyz; // diff
    
    return float4(diffuse + specular, 1.0);
}

//MARK: - Point Light
struct LightMaskOut {
    float4 position [[position]];
};

vertex LightMaskOut
light_mask_vertex(const device float4 *vertices [[ buffer(0) ]],
                  const device PointLightData *u_pointLight [[buffer(11)]],
                  constant matrix_float4x4 &u_VPMat [[buffer(3)]],
                  uint iid [[ instance_id ]],
                  uint vid [[ vertex_id ]]) {
    LightMaskOut out;
    
    // Transform light to position relative to the temple
    float4 vertex_eye_position = float4(vertices[vid].xyz * u_pointLight[iid].distance + u_pointLight[iid].position, 1);
    
    out.position = u_VPMat * vertex_eye_position;
    
    return out;
}

struct LightInOut {
    float4 position [[position]];
    float3 eye_position;
    uint iid [[flat]];
};

vertex LightInOut
deferred_point_lighting_vertex(const device float4 *vertices [[ buffer(0) ]],
                               const device PointLightData *u_pointLight [[ buffer(11) ]],
                               constant matrix_float4x4 &u_VPMat [[buffer(3)]],
                               uint iid [[ instance_id ]],
                               uint vid [[ vertex_id ]]) {
    LightInOut out;
    
    // Transform light to position relative to the temple
    float3 vertex_eye_position = vertices[vid].xyz * u_pointLight[iid].distance + u_pointLight[iid].position;
    
    out.position = u_VPMat * float4(vertex_eye_position, 1);
    
    // Sending light position in view space to next stage
    out.eye_position = vertex_eye_position;
    
    out.iid = iid;
    
    return out;
}

fragment float4
deferred_point_lighting_fragment_traditional(LightInOut in [[ stage_in ]],
                                             texture2d<float> diffuse_occlusion_GBuffer [[texture(0)]],
                                             texture2d<float> specular_roughness_GBuffer [[texture(1)]],
                                             texture2d<float> normal_GBuffer [[texture(2)]],
                                             texture2d<float> emissive_GBuffer [[texture(3)]],
                                             depth2d<float> depth_GBuffer [[texture(4)]],
                                             const device PointLightData *u_pointLight [[ buffer(11) ]]) {
    uint2 position = uint2(in.position.xy);
    float4 diffuse_occlusion = diffuse_occlusion_GBuffer.read(position.xy);
    float4 specular_roughness = specular_roughness_GBuffer.read(position.xy);
    float3 normal = normal_GBuffer.read(position.xy).xyz;
    float depth = depth_GBuffer.read(position.xy);
    
    float4 lighting = float4(0);
    // Used eye_space depth to determine the position of the fragment in eye_space
    float3 eye_space_fragment_pos = in.eye_position * (depth / in.eye_position.z);
    
    float3 light_eye_position = u_pointLight[in.iid].position;
    float light_distance = length(light_eye_position - eye_space_fragment_pos);
    float light_radius = u_pointLight[in.iid].distance;
    
    if (light_distance < light_radius) {
        float4 eye_space_light_pos = float4(light_eye_position,1);
        
        float3 eye_space_fragment_to_light = eye_space_light_pos.xyz - eye_space_fragment_pos;
        
        float3 light_direction = normalize(eye_space_fragment_to_light);
        
        float3 light_color = float3(u_pointLight[in.iid].color);
        
        // Diffuse contribution
        float4 diffuse_contribution = float4(diffuse_occlusion.xyz, specular_roughness.x)
        * max(dot(normal, light_direction),0.0f)
        * float4(light_color,1);
        
        // Specular Contribution
        float3 halfway_vector = normalize(eye_space_fragment_to_light - eye_space_fragment_pos);
        
        float specular_intensity = 32; // fix
        
        float specular_factor = powr(max(dot(float3(normal.xyz), float3(halfway_vector)),0.0), specular_intensity);
        
        float3 specular_contribution = specular_factor * float3(diffuse_occlusion.xyz) * light_color;
        
        // Light falloff
        float attenuation = 1.0 - (light_distance / light_radius);
        attenuation *= attenuation;
        
        lighting += (diffuse_contribution + float4(specular_contribution, 0)) * attenuation;
    }
    
    return lighting;
}
