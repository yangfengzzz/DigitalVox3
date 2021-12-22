//
//  shadow_common.metal
//  vox.render
//
//  Created by 杨丰 on 2021/12/22.
//

#include <metal_stdlib>
using namespace metal;
#include "shadow_common.h"

float textureProj(float3 worldPos, float2 off,
                  depth2d_array<float> u_shadowMap,
                  constant ShadowData* u_shadowData,
                  int index) {
    constexpr sampler s(coord::normalized, filter::linear,
                        address::clamp_to_edge, compare_func:: less);
    float4 shadowCoord = u_shadowData[index].vp[0] * float4(worldPos, 1.0);
    float2 xy = shadowCoord.xy;
    xy /= shadowCoord.w;
    xy = xy * 0.5 + 0.5;
    xy.y = 1 - xy.y;
    float shadow_sample = u_shadowMap.sample(s, xy + off, index);
    float current_sample = shadowCoord.z / shadowCoord.w;
    
    if (current_sample > shadow_sample ) {
        return u_shadowData[index].intensity;
    } else {
        return 1.0;
    }
}

float filterPCF(float3 worldPos, float3 viewPos,
                depth2d_array<float> u_shadowMap,
                constant ShadowData* u_shadowData,
                int index) {
    if (u_shadowData[index].cascadeSplits[0] < 0) {
        float4 shadowCoord = u_shadowData[index].vp[0] * float4(worldPos, 1.0);
        float2 xy = shadowCoord.xy;
        xy /= shadowCoord.w;
        xy = xy * 0.5 + 0.5;
        xy.y = 1 - xy.y;
        constexpr sampler s(coord::normalized, filter::linear,
                            address::clamp_to_edge, compare_func:: less);
        
        const int neighborWidth = 3;
        const float neighbors = (neighborWidth * 2.0 + 1.0) * (neighborWidth * 2.0 + 1.0);
        float mapSize = 4096;
        float texelSize = 1.0 / mapSize;
        float total = 0.0;
        for (int x = -neighborWidth; x <= neighborWidth; x++) {
            for (int y = -neighborWidth; y <= neighborWidth; y++) {
                float shadow_sample = u_shadowMap.sample(s, xy + float2(x, y) * texelSize, index);
                float current_sample = shadowCoord.z / shadowCoord.w;
                if (current_sample > shadow_sample ) {
                    total += u_shadowData[index].intensity;
                } else {
                    total += 1.0;
                }
            }
        }
        return total /= neighbors;
    } else {
        // Get cascade index for the current fragment's view position
        uint cascadeIndex = 0;
        for(uint i = 0; i < 4 - 1; ++i) {
            if(viewPos.z < u_shadowData[0].cascadeSplits[i]) {
                cascadeIndex = i + 1;
            }
        }
        
        float2 offset = float2();
        if (cascadeIndex == 1) {
            offset.x = 0.5;
        } else if (cascadeIndex == 2) {
            offset.y = 0.5;
        } else if (cascadeIndex == 3) {
            offset.x = 0.5;
            offset.y = 0.5;
        }
        
        float4 shadowCoord = u_shadowData[index].vp[cascadeIndex] * float4(worldPos, 1.0);
        float2 xy = shadowCoord.xy;
        xy /= shadowCoord.w;
        xy = xy * 0.5 + 0.5;
        xy.y = 1 - xy.y;
        constexpr sampler s(coord::normalized, filter::linear,
                            address::clamp_to_edge, compare_func:: less);
        
        const int neighborWidth = 3;
        const float neighbors = (neighborWidth * 2.0 + 1.0) * (neighborWidth * 2.0 + 1.0);
        float mapSize = 4096;
        float texelSize = 1.0 / mapSize;
        float total = 0.0;
        for (int x = -neighborWidth; x <= neighborWidth; x++) {
            for (int y = -neighborWidth; y <= neighborWidth; y++) {
                float shadow_sample = u_shadowMap.sample(s, xy + float2(x, y) * texelSize + offset, index);
                float current_sample = shadowCoord.z / shadowCoord.w;
                if (current_sample > shadow_sample ) {
                    total += u_shadowData[index].intensity;
                } else {
                    total += 1.0;
                }
            }
        }
        return total /= neighbors;
    }
}
