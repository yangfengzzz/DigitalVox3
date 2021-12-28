//
//  blend_state.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "blend_state.h"
#include "../../rhi-metal/metal_renderer.h"

namespace vox {
void BlendState::_platformApply(MTLRenderPipelineDescriptor *pipelineDescriptor,
                                MTLDepthStencilDescriptor *depthStencilDescriptor,
                                MetalRenderer *hardwareRenderer) {
    const auto enabled = targetBlendState.enabled;
    const auto colorBlendOperation = targetBlendState.colorBlendOperation;
    const auto alphaBlendOperation = targetBlendState.alphaBlendOperation;
    const auto sourceColorBlendFactor = targetBlendState.sourceColorBlendFactor;
    const auto destinationColorBlendFactor = targetBlendState.destinationColorBlendFactor;
    const auto sourceAlphaBlendFactor = targetBlendState.sourceAlphaBlendFactor;
    const auto destinationAlphaBlendFactor = targetBlendState.destinationAlphaBlendFactor;
    const auto colorWriteMask = targetBlendState.colorWriteMask;
    
    if (enabled) {
        pipelineDescriptor.colorAttachments[0].blendingEnabled = true;
    } else {
        pipelineDescriptor.colorAttachments[0].blendingEnabled = false;
    }
    
    if (enabled) {
        // apply blend factor.
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = sourceColorBlendFactor;
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = destinationColorBlendFactor;
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = sourceAlphaBlendFactor;
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = destinationAlphaBlendFactor;
        
        // apply blend operation.
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = colorBlendOperation;
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = alphaBlendOperation;
        
        // apply blend color.
        hardwareRenderer->setBlendColor(blendColor.r, blendColor.g, blendColor.b, blendColor.a);
    }
    
    // apply color mask.
    pipelineDescriptor.colorAttachments[0].writeMask = colorWriteMask;
    
    // apply alpha to coverage.
    if (alphaToCoverage) {
        pipelineDescriptor.alphaToCoverageEnabled = true;
    } else {
        pipelineDescriptor.alphaToCoverageEnabled = false;
    }
}
}
