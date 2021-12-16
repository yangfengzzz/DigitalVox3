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
    float4 color [[attribute(3)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 outNormal;
    float4 outColor;
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
    out.outColor = vertexIn.color;
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
