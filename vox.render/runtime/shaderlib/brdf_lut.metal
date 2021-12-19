//
//  BRDF.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

#include <metal_stdlib>
using namespace metal;
#include "pbr_common.h"

kernel void integrateBRDF(texture2d<float, access::write> lut [[ texture(0) ]],
                          uint2 position [[ thread_position_in_grid ]]) {
    
    float width = lut.get_width();
    float height = lut.get_height();
    if (position.x >= width || position.y >= height) {
        return;
    }
    float Roughness = (position.x + 16.0) / width;
    float NoV = (position.y + 1.0) / height;
    
    // input (Roughness and cosTheta) - output (scale and bias to F0)
    float2 brdf = IntegrateBRDF(Roughness, NoV);
    float4 color(brdf, 0, 0);
    lut.write(color, position);
}
