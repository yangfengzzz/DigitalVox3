//
//  color_render_pass.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#include "color_render_pass.h"
#include "../camera.h"
#include "../engine.h"
#include <GLFW/glfw3.h>

namespace vox {
namespace picker {
ColorRenderPass::ColorRenderPass(const std::string& name, int priority,
                                 MTLRenderPassDescriptor* renderTarget, Layer mask, Engine* engine):
RenderPass(name, priority, renderTarget, mask){
    Shader::create("framebuffer-picker-color", "vertex_picker", "fragment_picker");
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
    const auto& screenPoint = _pickPos;
    auto window =  camera->engine()->canvas()->handle();
    int clientWidth, clientHeight;
    glfwGetWindowSize(window, &clientWidth, &clientHeight);
    int canvasWidth, canvasHeight;
    glfwGetFramebufferSize(window, &canvasWidth, &canvasHeight);
    
    const auto px = (screenPoint.x / clientWidth) * canvasWidth;
    const auto py = (screenPoint.y / clientHeight) * canvasHeight;
    
    const auto viewport = camera->viewport();
    const auto viewWidth = (viewport.z - viewport.x) * canvasWidth;
    const auto viewHeight = (viewport.w - viewport.y) * canvasHeight;
    
    const auto nx = (px - viewport.x) / viewWidth;
    const auto ny = (py - viewport.y) / viewHeight;
    auto texture = renderTarget.colorAttachments[0].texture;
    const auto left = std::floor(nx * (texture.width - 1));
    const auto bottom = std::floor((1 - ny) * (texture.height - 1));
    std::array<uint8_t, 4> pixel;
    
    [renderTarget.colorAttachments[0].texture getBytes:pixel.data()
                                           bytesPerRow:sizeof(uint8_t)*4
                                            fromRegion:MTLRegionMake2D(left, bottom, 1, 1)
                                           mipmapLevel:0];
    
    return pixel;
}

}
}
