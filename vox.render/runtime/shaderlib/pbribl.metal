//
//  pbribl.metal
//  vox.render
//
//  Created by 杨丰 on 2021/12/18.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.h"

//MARK: - brdflut
// Based omn http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
float random(float2 co) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy ,float2(a,b));
    float sn= fmod(dt,3.14);
    return fract(sin(sn) * c);
}

float2 hammersley2d(uint i, uint N) {
    // Radical inverse based on http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
    uint bits = (i << 16u) | (i >> 16u);
    bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
    bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
    bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
    bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
    float rdi = float(bits) * 2.3283064365386963e-10;
    return float2(float(i) /float(N), rdi);
}

// Based on http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_slides.pdf
float3 importanceSample_GGX(float2 Xi, float roughness, float3 normal) {
    // Maps a 2D point to a hemisphere with spread based on roughness
    float alpha = roughness * roughness;
    float phi = 2.0 * M_PI_F * Xi.x + random(normal.xz) * 0.1;
    float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (alpha*alpha - 1.0) * Xi.y));
    float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
    float3 H = float3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);
    
    // Tangent space
    float3 up = abs(normal.z) < 0.999 ? float3(0.0, 0.0, 1.0) : float3(1.0, 0.0, 0.0);
    float3 tangentX = normalize(cross(up, normal));
    float3 tangentY = normalize(cross(normal, tangentX));
    
    // Convert to world Space
    return normalize(tangentX * H.x + tangentY * H.y + normal * H.z);
}

// Geometric Shadowing function
float G_SchlicksmithGGX(float dotNL, float dotNV, float roughness) {
    float k = (roughness * roughness) / 2.0;
    float GL = dotNL / (dotNL * (1.0 - k) + k);
    float GV = dotNV / (dotNV * (1.0 - k) + k);
    return GL * GV;
}

constant uint NUM_SAMPLES = 1024u;
float2 BRDF(float NoV, float roughness) {
    // Normal always points along z-axis for the 2D lookup
    const float3 N = float3(0.0, 0.0, 1.0);
    float3 V = float3(sqrt(1.0 - NoV*NoV), 0.0, NoV);
    
    float2 LUT = float2(0.0);
    for(uint i = 0u; i < NUM_SAMPLES; i++) {
        float2 Xi = hammersley2d(i, NUM_SAMPLES);
        float3 H = importanceSample_GGX(Xi, roughness, N);
        float3 L = 2.0 * dot(V, H) * H - V;
        
        float dotNL = max(dot(N, L), 0.0);
        float dotNV = max(dot(N, V), 0.0);
        float dotVH = max(dot(V, H), 0.0);
        float dotNH = max(dot(H, N), 0.0);
        
        if (dotNL > 0.0) {
            float G = G_SchlicksmithGGX(dotNL, dotNV, roughness);
            float G_Vis = (G * dotVH) / (dotNH * dotNV);
            float Fc = pow(1.0 - dotVH, 5.0);
            LUT += float2((1.0 - Fc) * G_Vis, Fc * G_Vis);
        }
    }
    return LUT / float(NUM_SAMPLES);
}

fragment float4 brdflut_experimental(float4 uv [[stage_in]]) {
    return float4(BRDF(uv.x, 1.0 - uv.y), 0.0, 1.0);
}

//MARK: - filterCube
struct FilterCubeIn {
    float3 position [[attribute(0)]];
};

struct FilterCubeOut {
    float4 position [[position]];
    float3 uvw;
};

vertex FilterCubeOut filterCube_experimental(const FilterCubeIn in [[stage_in]],
                                             constant matrix_float4x4 &u_MVPMat [[buffer(5)]]) {
    FilterCubeOut out;
    out.uvw = in.position;
    out.position = u_MVPMat * float4(in.position, 1.0);
    
    return out;
}

//MARK: - Irradiance cube
fragment float4 irradiance_experimental(FilterCubeOut in [[stage_in]],
                                        sampler textureSampler [[sampler(0)]],
                                        texturecube<float> samplerEnv [[texture(0)]],
                                        constant float &deltaPhi [[buffer(2)]],
                                        constant float &deltaTheta [[buffer(3)]]) {
    float3 N = normalize(in.uvw);
    float3 up = float3(0.0, 1.0, 0.0);
    float3 right = normalize(cross(up, N));
    up = cross(N, right);
    
    const float TWO_PI = M_PI_F * 2.0;
    const float HALF_PI = M_PI_F * 0.5;
    
    float3 color = float3(0.0);
    uint sampleCount = 0u;
    for (float phi = 0.0; phi < TWO_PI; phi += deltaPhi) {
        for (float theta = 0.0; theta < HALF_PI; theta += deltaTheta) {
            float3 tempVec = cos(phi) * right + sin(phi) * up;
            float3 sampleVector = cos(theta) * N + sin(theta) * tempVec;
            color += samplerEnv.sample(textureSampler, sampleVector).rgb * cos(theta) * sin(theta);
            sampleCount++;
        }
    }
    return float4(M_PI_F * color / float(sampleCount), 1.0);
}

//MARK: - PrefilterEnvMap
float D_GGX(float dotNH, float roughness) {
    float alpha = roughness * roughness;
    float alpha2 = alpha * alpha;
    float denom = dotNH * dotNH * (alpha2 - 1.0) + 1.0;
    return (alpha2)/(M_PI_F * denom*denom);
}

float3 prefilterEnvMap(float3 R, float roughness, uint numSamples,
                       sampler textureSampler, texturecube<float> samplerEnv) {
    float3 N = R;
    float3 V = R;
    float3 color = float3(0.0);
    float totalWeight = 0.0;
    float envMapDim = float(samplerEnv.get_width());
    for(uint i = 0u; i < numSamples; i++) {
        float2 Xi = hammersley2d(i, numSamples);
        float3 H = importanceSample_GGX(Xi, roughness, N);
        float3 L = 2.0 * dot(V, H) * H - V;
        float dotNL = clamp(dot(N, L), 0.0, 1.0);
        if(dotNL > 0.0) {
            // Filtering based on https://placeholderart.wordpress.com/2015/07/28/implementation-notes-runtime-environment-map-filtering-for-image-based-lighting/
            
            float dotNH = clamp(dot(N, H), 0.0, 1.0);
            float dotVH = clamp(dot(V, H), 0.0, 1.0);
            
            // Probability Distribution Function
            float pdf = D_GGX(dotNH, roughness) * dotNH / (4.0 * dotVH) + 0.0001;
            // Slid angle of current smple
            float omegaS = 1.0 / (float(numSamples) * pdf);
            // Solid angle of 1 pixel across all cube faces
            float omegaP = 4.0 * M_PI_F / (6.0 * envMapDim * envMapDim);
            // Biased (+1.0) mip level for better result
            float mipLevel = roughness == 0.0 ? 0.0 : max(0.5 * log2(omegaS / omegaP) + 1.0, 0.0f);
            color += samplerEnv.sample(textureSampler, L, level(mipLevel)).rgb * dotNL;
            totalWeight += dotNL;
            
        }
    }
    return (color / totalWeight);
}

fragment float4 prefilterEnv_experimental(FilterCubeOut in [[stage_in]],
                                          sampler textureSampler [[sampler(0)]],
                                          texturecube<float> samplerEnv [[texture(0)]],
                                          constant float &roughness [[buffer(2)]],
                                          constant uint &numSamples [[buffer(3)]]) {
    float3 N = normalize(in.uvw);
    return float4(prefilterEnvMap(N, roughness, numSamples, textureSampler, samplerEnv), 1.0);
}

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
                                      constant float3 &u_cameraPos [[buffer(7)]],
                                      constant float &exposure [[buffer(8)]],
                                      constant float &gamma [[buffer(9)]],
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
                                      texture2d<float> u_occlusionTexture [[texture(7), function_constant(hasOcclusionMap)]],
                                      texture2d<float> samplerBRDFLUT [[texture(8)]],
                                      texturecube<float> samplerIrradiance [[texture(9)]],
                                      texturecube<float> prefilteredMap [[texture(10)]]) {
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
    float3 reflection = prefilteredReflection(R, u_roughness, textureSampler, prefilteredMap).rgb;
    float3 irradiance = samplerIrradiance.sample(textureSampler, N).rgb;
    
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
    // Gamma correction
    color = pow(color, float3(1.0f / gamma));
    
    return float4(color, 1.0);
}
