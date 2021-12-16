//
//  gltfloading.metal
//  vox.render
//
//  Created by 杨丰 on 2021/12/16.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.h"

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 outNormal;
    float2 outUV;
    float3 outViewVec;
    float3 outLightVec;
};

vertex VertexOut vertex_experimental(const VertexIn vertexIn [[stage_in]],
                                     constant matrix_float4x4 &u_localMat [[buffer(0)]],
                                     constant matrix_float4x4 &u_modelMat [[buffer(1)]],
                                     constant matrix_float4x4 &u_viewMat [[buffer(2)]],
                                     constant matrix_float4x4 &u_projMat [[buffer(3)]],
                                     constant matrix_float4x4 &u_MVMat [[buffer(4)]],
                                     constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                                     constant matrix_float4x4 &u_normalMat [[buffer(6)]],
                                     constant float3 &u_cameraPos [[buffer(7)]],
                                     constant float4 &u_tilingOffset [[buffer(8)]],
                                     constant float3 *u_pointLightColor [[buffer(12), function_constant(hasPointLight)]],
                                     constant float3 *u_pointLightPosition [[buffer(13), function_constant(hasPointLight)]],
                                     constant float *u_pointLightDistance [[buffer(14), function_constant(hasPointLight)]]) {
    VertexOut out;
    out.outNormal = vertexIn.normal;
    out.outUV = vertexIn.uv;
    out.position = u_MVPMat * float4(vertexIn.position, 1.0);
    
    float4 pos = u_viewMat * float4(vertexIn.position, 1.0);
    matrix_float3x3 view3x3 = matrix_float3x3(u_viewMat[0].xyz, u_viewMat[1].xyz, u_viewMat[2].xyz);
    out.outNormal = view3x3 * vertexIn.normal;
    float3 lPos = view3x3 * u_pointLightPosition[0];
    out.outLightVec = lPos - pos.xyz;
    out.outViewVec = -pos.xyz;
    
    return out;
}

fragment float4 fragment_experimental(VertexOut in [[stage_in]],
                                      sampler textureSampler [[sampler(0)]],
                                      //pbr base frag define
                                      constant float &u_alphaCutoff [[buffer(21)]],
                                      constant float4 &u_baseColor [[buffer(22)]],
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
    float4 color = u_baseColorTexture.sample(textureSampler, in.outUV);

    float3 N = normalize(in.outNormal);
    float3 L = normalize(in.outLightVec);
    float3 V = normalize(in.outViewVec);
    float3 R = reflect(-L, N);
    float4 diffuse = max(dot(N, L), 0.15) * float4(1.0);
    float4 specular = pow(max(dot(R, V), 0.0), 16.0) * float4(0.75);
    
    float4 final = diffuse * color + specular;
    return float4(final.rgb, 1.0);
}
