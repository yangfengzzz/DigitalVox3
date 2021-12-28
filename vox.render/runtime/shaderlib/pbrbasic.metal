//
//  pbrbasic.metal
//  vox.render
//
//  Created by 杨丰 on 2021/12/18.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.h"

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float3 worldPos;
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
    out.position = u_MVPMat * float4(in.position, 1.0);
    
    return out;
}

//MARK: - Fragment
// Normal Distribution function --------------------------------------
float D_GGX(float dotNH, float roughness) {
    float alpha = roughness * roughness;
    float alpha2 = alpha * alpha;
    float denom = dotNH * dotNH * (alpha2 - 1.0) + 1.0;
    return (alpha2)/(M_PI_F * denom*denom);
}

// Geometric Shadowing function --------------------------------------
float G_SchlicksmithGGX(float dotNL, float dotNV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;
    float GL = dotNL / (dotNL * (1.0 - k) + k);
    float GV = dotNV / (dotNV * (1.0 - k) + k);
    return GL * GV;
}

// Fresnel function ----------------------------------------------------
float3 F_Schlick(float cosTheta, float metallic, float3 u_baseColor) {
    float3 F0 = mix(float3(0.04), u_baseColor, metallic); // * material.specular
    float3 F = F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
    return F;
}

// Specular BRDF composition --------------------------------------------

float3 BRDF(float3 L, float3 V, float3 N, float metallic, float roughness, float3 u_baseColor) {
    // Precalculate vectors and dot products
    float3 H = normalize (V + L);
    float dotNV = clamp(dot(N, V), 0.0, 1.0);
    float dotNL = clamp(dot(N, L), 0.0, 1.0);
    float dotNH = clamp(dot(N, H), 0.0, 1.0);
    
    // Light color fixed
    float3 lightColor = float3(1.0);
    
    float3 color = float3(0.0);
    
    if (dotNL > 0.0) {
        float rroughness = max(0.05, roughness);
        // D = Normal distribution (Distribution of the microfacets)
        float D = D_GGX(dotNH, roughness);
        // G = Geometric shadowing term (Microfacets shadowing)
        float G = G_SchlicksmithGGX(dotNL, dotNV, rroughness);
        // F = Fresnel factor (Reflectance depending on angle of incidence)
        float3 F = F_Schlick(dotNV, metallic, u_baseColor);
        
        float3 spec = D * F * G / (4.0 * dotNL * dotNV);
        
        color += spec * dotNL * lightColor;
    }
    
    return color;
}


fragment float4 fragment_experimental(VertexOut in [[stage_in]],
                                      sampler textureSampler [[sampler(0)]],
                                      constant float3 &u_cameraPos [[buffer(7)]],
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
                                      texture2d<float> u_baseColorTexture [[texture(1), function_constant(hasBaseColorMap)]],
                                      texture2d<float> u_normalTexture [[texture(2), function_constant(hasNormalTexture)]],
                                      texture2d<float> u_emissiveTexture [[texture(3), function_constant(hasEmissiveMap)]],
                                      texture2d<float> u_metallicRoughnessTexture [[texture(4), function_constant(hasMetalRoughnessMap)]],
                                      texture2d<float> u_specularTexture [[texture(5), function_constant(hasSpecularMap)]],
                                      texture2d<float> u_glossinessTexture [[texture(6), function_constant(hasGlossinessMap)]],
                                      texture2d<float> u_occlusionTexture [[texture(7), function_constant(hasOcclusionMap)]]) {
    float3 N = normalize(in.normal);
    float3 V = normalize(u_cameraPos - in.worldPos);

    // Specular contribution
    float3 Lo = float3(0.0);
    for (int i = 0; i < directLightCount; i++) {
        float3 L = normalize(u_directLightDirection[i].xyz);
        Lo += BRDF(L, V, N, u_metal, u_roughness, u_baseColor);
    };
    
    // Combine with ambient
    float3 color = u_baseColor * 0.02;
    color += Lo;

    return float4(color, 1.0);
}
