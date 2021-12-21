//
//  shadow-map.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/23.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.h"

struct VertexIn {
    float3 position [[ attribute(0) ]];
};

vertex float4 vertex_depth(const VertexIn vertexIn [[ stage_in ]],
                           constant matrix_float4x4 &vp [[buffer(1)]],
                           constant matrix_float4x4 &modelMatrix [[buffer(2)]]) {
    return vp * modelMatrix * float4(vertexIn.position, 1.0);
}
