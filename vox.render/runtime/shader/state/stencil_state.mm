//
//  stencil_state.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "stencil_state.h"
#include "../../rhi-metal/metal_renderer.h"

namespace vox {
void StencilState::_platformApply(MTLRenderPipelineDescriptor *pipelineDescriptor,
                                  MTLDepthStencilDescriptor *depthStencilDescriptor,
                                  MetalRenderer *hardwareRenderer) {
    if (enabled) {
        // apply stencil func.
        depthStencilDescriptor.frontFaceStencil.stencilCompareFunction = compareFunctionFront;
        depthStencilDescriptor.frontFaceStencil.readMask = mask;
        
        depthStencilDescriptor.backFaceStencil.stencilCompareFunction = compareFunctionBack;
        depthStencilDescriptor.backFaceStencil.readMask = mask;
        
        hardwareRenderer->setStencilReferenceValue(referenceValue);
    }
    
    // apply stencil operation.
    depthStencilDescriptor.frontFaceStencil.stencilFailureOperation = failOperationFront;
    depthStencilDescriptor.frontFaceStencil.depthFailureOperation = zFailOperationFront;
    depthStencilDescriptor.frontFaceStencil.depthStencilPassOperation = passOperationFront;
    
    depthStencilDescriptor.backFaceStencil.stencilFailureOperation = failOperationBack;
    depthStencilDescriptor.backFaceStencil.depthFailureOperation = zFailOperationBack;
    depthStencilDescriptor.backFaceStencil.depthStencilPassOperation = passOperationBack;
    
    // apply write mask.
    depthStencilDescriptor.frontFaceStencil.writeMask = writeMask;
    depthStencilDescriptor.backFaceStencil.writeMask = writeMask;
}
}

