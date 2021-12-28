//
//  raster_state.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "raster_state.h"
#include "../../rhi-metal/metal_renderer.h"

namespace vox {
void RasterState::_platformApply(MTLRenderPipelineDescriptor *pipelineDescriptor,
                                 MTLDepthStencilDescriptor *depthStencilDescriptor,
                                 MetalRenderer *hardwareRenderer) {
    bool cullFaceEnable = cullMode != MTLCullModeNone;
    
    // apply front face.
    if (cullFaceEnable) {
        hardwareRenderer->setCullMode(cullMode);
    }
    
    // apply polygonOffset.
    if (depthBias != 0 || slopeScaledDepthBias != 0) {
        hardwareRenderer->setDepthBias(depthBias, slopeScaledDepthBias, 0);
    }
}

}
