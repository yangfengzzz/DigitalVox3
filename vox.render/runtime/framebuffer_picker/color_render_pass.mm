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
                                 MTLRenderPassDescriptor* renderTarget, Layer mask, Engine* engine):
RenderPass(name, priority, renderTarget, mask){
    _material = std::make_shared<ColorMaterial>(engine);
    _needPick = false;
}

void ColorRenderPass::setPickFunctor(std::function<void(Renderer*, MeshPtr)> func) {
    _onPick = func;
}

MaterialPtr ColorRenderPass::material(const RenderElement& element) {
    _material->_preRender(element);
    return _material;
}

void ColorRenderPass::preRender(Camera* camera, const RenderQueue& opaqueQueue,
                                const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) {
    if (_needPick) {
        enabled = true;
        _material->reset();
    } else {
        enabled = false;
    }
}

void ColorRenderPass::postRender(Camera* camera, const RenderQueue& opaqueQueue,
                                 const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) {
    if (_needPick) {
        auto color = readColorFromRenderTarget(camera);
        auto object = _material->getObjectByColor(color);
        _needPick = false;
        
        if (_onPick) _onPick(object.first, object.second);
    }
}

void ColorRenderPass::pick(const math::Float2& pos) {
    _pickPos = pos;
    _needPick = true;
}


std::array<uint8_t, 4> ColorRenderPass::readColorFromRenderTarget(Camera* camera) {
    return {};
}

}
}
