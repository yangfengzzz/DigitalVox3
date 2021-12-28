//
//  pbribl.metal
//  vox.render
//
//  Created by 杨丰 on 2021/12/18.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.h"

//MARK: - pbribl
struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float3 worldPos;
    float2 uv;
};

vertex VertexOut vertex_experimental(const VertexIn in [[stage_in]],
                                     constant matrix_float4x4 &u_localMat [[buffer(0)]],
                                     constant matrix_float4x4 &u_modelMat [[buffer(1)]],
                                     constant matrix_float4x4 &u_viewMat [[buffer(2)]],
                                     constant matrix_float4x4 &u_projMat [[buffer(3)]],
                                     constant matrix_float4x4 &u_MVMat [[buffer(4)]],
                                     constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                                     constant matrix_float4x4 &u_normalMat [[buffer(6)]],
                                     constant float3 &u_cameraPos [[buffer(7)]],
                                     constant float4 &u_tilingOffset [[buffer(8)]]) {
    VertexOut out;
    out.worldPos = (u_modelMat * float4(in.position, 1.0)).xyz;
    out.normal = (u_normalMat * float4(in.normal, 0.0)).xyz;
    out.uv = in.uv;
    out.position = u_MVPMat * float4(in.position, 1.0);
    
    return out;
}

float D_GGX(float dotNH, float roughness) {
    float alpha = roughness * roughness;
    float alpha2 = alpha * alpha;
    float denom = dotNH * dotNH * (alpha2 - 1.0) + 1.0;
    return (alpha2)/(M_PI_F * denom*denom);
}

// Geometric Shadowing function
float G_SchlicksmithGGX(float dotNL, float dotNV, float roughness) {
    float k = (roughness * roughness) / 2.0;
    float GL = dotNL / (dotNL * (1.0 - k) + k);
    float GV = dotNV / (dotNV * (1.0 - k) + k);
    return GL * GV;
}

// From http://filmicgames.com/archives/75
float3 Uncharted2Tonemap(float3 x) {
    float A = 0.15;
    float B = 0.50;
    float C = 0.10;
    float D = 0.20;
    float E = 0.02;
    float F = 0.30;
    return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

float3 F_Schlick(float cosTheta, float3 F0) {
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}
float3 F_SchlickR(float cosTheta, float3 F0, float roughness) {
    return F0 + (max(float3(1.0 - roughness), F0) - F0) * pow(1.0 - cosTheta, 5.0);
}

float3 prefilteredReflection(float3 R, float roughness,
                             sampler textureSampler,
                             texturecube<float> prefilteredMap) {
    const float MAX_REFLECTION_LOD = 9.0; // todo: param/const
    float lod = roughness * MAX_REFLECTION_LOD;
    float lodf = floor(lod);
    float lodc = ceil(lod);
    float3 a = prefilteredMap.sample(textureSampler, R, level(lodf)).rgb;
    float3 b = prefilteredMap.sample(textureSampler, R, level(lodc)).rgb;
    return mix(a, b, lod - lodf);
}

float3 specularContribution(float3 L, float3 V, float3 N, float3 F0,
                            float metallic, float roughness, float3 u_baseColor) {
    // Precalculate vectors and dot products
    float3 H = normalize (V + L);
    float dotNH = clamp(dot(N, H), 0.0, 1.0);
    float dotNV = clamp(dot(N, V), 0.0, 1.0);
    float dotNL = clamp(dot(N, L), 0.0, 1.0);
    
    float3 color = float3(0.0);
    if (dotNL > 0.0) {
        // D = Normal distribution (Distribution of the microfacets)
        float D = D_GGX(dotNH, roughness);
        // G = Geometric shadowing term (Microfacets shadowing)
        float G = G_SchlicksmithGGX(dotNL, dotNV, roughness);
        // F = Fresnel factor (Reflectance depending on angle of incidence)
        float3 F = F_Schlick(dotNV, F0);
        float3 spec = D * F * G / (4.0 * dotNL * dotNV + 0.001);
        float3 kD = (float3(1.0) - F) * (1.0 - metallic);
        color += (kD * u_baseColor / M_PI_F + spec) * dotNL;
    }
    
    return color;
}

fragment float4 fragment_experimental(VertexOut in [[stage_in]],
                                      sampler textureSampler [[sampler(0)]],
                                      constant float3 &u_cameraPos [[buffer(5)]],
                                      constant float &exposure [[buffer(6)]],
                                      constant EnvMapLight &u_envMapLight [[buffer(8)]],
                                      constant float3 *u_env_sh [[buffer(9), function_constant(hasSH)]],
                                      texturecube<float> u_env_specularTexture [[texture(0), function_constant(hasSpecularEnv)]],
                                      texturecube<float> u_env_diffuseTexture [[texture(1), function_constant(hasDiffuseEnv)]],
                                      texture2d<float> samplerBRDFLUT [[texture(2)]],
                                      // direction_light_frag
                                      constant float3 *u_directLightColor [[buffer(10), function_constant(hasDirectLight)]],
                                      constant float3 *u_directLightDirection [[buffer(11), function_constant(hasDirectLight)]],
                                      //pbr base frag define
                                      constant float &u_alphaCutoff [[buffer(21)]],
                                      constant float3 &u_baseColor [[buffer(22)]],
                                      constant float &u_metal [[buffer(23)]],
                                      constant float &u_roughness [[buffer(24)]],
                                      constant float3 &u_specularColor [[buffer(25)]],
                                      constant float &u_glossinessFactor [[buffer(26)]],
                                      constant float3 &u_emissiveColor [[buffer(27)]],
                                      constant float &u_normalIntensity [[buffer(28)]],
                                      constant float &u_occlusionStrength [[buffer(29)]],
                                      // pbr_texture_frag_define
                                      texture2d<float> u_baseColorTexture [[texture(3), function_constant(hasBaseColorMap)]],
                                      texture2d<float> u_normalTexture [[texture(4), function_constant(hasNormalTexture)]],
                                      texture2d<float> u_emissiveTexture [[texture(5), function_constant(hasEmissiveMap)]],
                                      texture2d<float> u_metallicRoughnessTexture [[texture(6), function_constant(hasMetalRoughnessMap)]],
                                      texture2d<float> u_specularTexture [[texture(7), function_constant(hasSpecularMap)]],
                                      texture2d<float> u_glossinessTexture [[texture(8), function_constant(hasGlossinessMap)]],
                                      texture2d<float> u_occlusionTexture [[texture(9), function_constant(hasOcclusionMap)]]) {
    float3 N = normalize(in.normal);
    float3 V = normalize(u_cameraPos - in.worldPos);
    float3 R = reflect(-V, N);
    
    float3 F0 = float3(0.04);
    F0 = mix(F0, u_baseColor, u_metal);
    
    float3 Lo = float3(0.0);
    for(int i = 0; i < directLightCount; i++) {
        float3 L = u_directLightDirection[i];
        Lo += specularContribution(L, V, N, F0, u_metal, u_roughness, u_baseColor);
    }
    
    float2 brdf = samplerBRDFLUT.sample(textureSampler, float2(max(dot(N, V), 0.0), u_roughness)).rg;
    float3 reflection = prefilteredReflection(R, u_roughness, textureSampler, u_env_specularTexture).rgb;
    float3 irradiance = u_env_diffuseTexture.sample(textureSampler, N).rgb;
    
    // Diffuse based on irradiance
    float3 diffuse = irradiance * u_baseColor;
    
    float3 F = F_SchlickR(max(dot(N, V), 0.0), F0, u_roughness);
    
    // Specular reflectance
    float3 specular = reflection * (F * brdf.x + brdf.y);
    
    // Ambient part
    float3 kD = 1.0 - F;
    kD *= 1.0 - u_metal;
    float3 ambient = (kD * diffuse + specular);
    
    float3 color = ambient + Lo;
    
    // Tone mapping
    color = Uncharted2Tonemap(color * exposure);
    color = color * (1.0f / Uncharted2Tonemap(float3(11.2f)));
    
    return float4(color, 1.0);
}
