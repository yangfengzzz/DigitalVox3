//
//  shader-common.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/23.
//

#include <metal_stdlib>
using namespace metal;

float4x4 getJointMatrix(sampler smp, texture2d<float> joint_tex,
                        float index, int u_jointCount) {
    float base = index / u_jointCount;
    float hf = 0.5 / u_jointCount;
    float v = base + hf;
    
    float4 m0 = joint_tex.sample(smp, float2(0.125, v));
    float4 m1 = joint_tex.sample(smp, float2(0.375, v));
    float4 m2 = joint_tex.sample(smp, float2(0.625, v));
    float4 m3 = joint_tex.sample(smp, float2(0.875, v));
    
    return float4x4(m0, m1, m2, m3);
}
