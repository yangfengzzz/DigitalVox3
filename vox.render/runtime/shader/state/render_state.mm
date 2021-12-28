//
//  render_state.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "render_state.h"
#include "engine.h"

namespace vox {
void RenderState::_apply(Engine *engine,
                         MTLRenderPipelineDescriptor *pipelineDescriptor,
                         MTLDepthStencilDescriptor *depthStencilDescriptor) {
    auto *hardwareRenderer = &engine->_hardwareRenderer;
    blendState._apply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer);
    depthState._apply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer);
    stencilState._apply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer);
    rasterState._apply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer);
}
}
