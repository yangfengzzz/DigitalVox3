//
//  color_render_pass.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#include "color_render_pass.h"

namespace vox {
namespace picker {
ColorRenderPass::ColorRenderPass(const std::string& name, int priority,
                                 MTLRenderPassDescriptor* renderTarget, Layer mask, Engine* engine) {
    
}

void ColorRenderPass::setPickFunctor(std::function<void(void)> func) {
    
}

MaterialPtr ColorRenderPass::material(const RenderElement& element) {
    return nullptr;
}

void ColorRenderPass::preRender(Camera* camera, const RenderQueue& opaqueQueue,
                                const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) {
    
}

void ColorRenderPass::postRender(Camera* camera, const RenderQueue& opaqueQueue,
                                 const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) {
    
}

void ColorRenderPass::pick(const math::Float2& pos) {
    
}


void ColorRenderPass::readColorFromRenderTarget(Camera* camera) {
    
}

}
}
