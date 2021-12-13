//
//  editor-grid.metal
//  editor
//
//  Created by 杨丰 on 2021/12/12.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

typedef struct {
    float3 position [[attribute(0)]];
} VertexIn;

typedef struct {
    float4 position [[position]];
    float3 nearPoint;
    float3 farPoint;
    
    float4 fragView0;
    float4 fragView1;
    float4 fragView2;
    float4 fragView3;
    
    float4 fragProj0;
    float4 fragProj1;
    float4 fragProj2;
    float4 fragProj3;
} VertexOut;

float3 UnprojectPoint(float x, float y, float z, matrix_float4x4 viewInv, matrix_float4x4 projInv) {
    float4 unprojectedPoint =  viewInv * projInv * float4(x, y, z, 1.0);
    return unprojectedPoint.xyz / unprojectedPoint.w;
}

vertex VertexOut vertex_grid(const VertexIn in [[stage_in]],
                             constant matrix_float4x4 &u_viewMat [[buffer(7)]],
                             constant matrix_float4x4 &u_projMat [[buffer(8)]],
                             constant matrix_float4x4 &u_viewInvMat [[buffer(9)]],
                             constant matrix_float4x4 &u_projInvMat [[buffer(10)]]) {
    VertexOut out;
    
    out.nearPoint = UnprojectPoint(in.position.x, in.position.y, 0.0, u_viewInvMat, u_projInvMat).xyz; // unprojecting on the near plane
    out.farPoint = UnprojectPoint(in.position.x, in.position.y, 1.0, u_viewInvMat, u_projInvMat).xyz; // unprojecting on the far plane
    out.fragView0 = u_viewMat.columns[0];
    out.fragView1 = u_viewMat.columns[1];
    out.fragView2 = u_viewMat.columns[2];
    out.fragView3 = u_viewMat.columns[3];
    out.fragProj0 = u_projMat.columns[0];
    out.fragProj1 = u_projMat.columns[1];
    out.fragProj2 = u_projMat.columns[2];
    out.fragProj3 = u_projMat.columns[3];
    out.position = float4(in.position, 1.0);
    
    return out;
}

float4 grid(float3 fragPos3D, float scale, bool drawAxis) {
    float2 coord = fragPos3D.xz * scale; // use the scale variable to set the distance between the lines
    float2 derivative = fwidth(coord);
    float2 grid = abs(fract(coord - 0.5) - 0.5) / derivative;
    float line = min(grid.x, grid.y);
    float minimumz = min(derivative.y, 1.0);
    float minimumx = min(derivative.x, 1.0);
    float4 color = float4(0.6, 0.6, 0.6, 1.0 - min(line, 1.0));
    // z axis
    if(fragPos3D.x > -1 * minimumx && fragPos3D.x < 1 * minimumx) {
        color = float4(0.0, 0.0, 1.0, 1.0);
    }
    // x axis
    if(fragPos3D.z > -1 * minimumz && fragPos3D.z < 1 * minimumz) {
        color = float4(1.0, 0.0, 0.0, 1.0);
    }
    
    return color;
}

float computeDepth(float3 pos, matrix_float4x4 fragView, matrix_float4x4 fragProj) {
    float4 clip_space_pos = fragProj * fragView * float4(pos.xyz, 1.0);
    return (clip_space_pos.z / clip_space_pos.w);
}

float computeLinearDepth(float3 pos, matrix_float4x4 fragView, matrix_float4x4 fragProj) {
    float near = 0.01;
    float far = 100;
    
    float4 clip_space_pos = fragProj * fragView * float4(pos.xyz, 1.0);
    float clip_space_depth = (clip_space_pos.z / clip_space_pos.w) * 2.0 - 1.0; // put back between -1 and 1
    float linearDepth = (2.0 * near * far) / (far + near - clip_space_depth * (far - near)); // get linear value between 0.01 and 100
    return linearDepth / far; // normalize
}

struct fragmentOut {
    float4 color[[color(0)]];
    float depth[[depth(greater)]];
};

fragment fragmentOut fragment_grid(VertexOut in [[stage_in]]) {
    float t = -in.nearPoint.y / (in.farPoint.y - in.nearPoint.y);
    float3 fragPos3D = in.nearPoint + t * (in.farPoint - in.nearPoint);
    
    matrix_float4x4 fragView = matrix_float4x4(in.fragView0, in.fragView1, in.fragView2, in.fragView3);
    matrix_float4x4 fragProj = matrix_float4x4(in.fragProj0, in.fragProj1, in.fragProj2, in.fragProj3);
    float depth = computeDepth(fragPos3D, fragView, fragProj);
    
    float linearDepth = computeLinearDepth(fragPos3D, fragView, fragProj);
    float fading = max(0.0, (0.5 - linearDepth));
    
    fragmentOut out;
    out.color = (grid(fragPos3D, 1, true)) * float(t > 0);
    out.color.a *= fading;
    out.depth = depth;
    
    return out;
}
