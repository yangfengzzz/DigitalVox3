//
//  framebuffer_picker.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#include "framebuffer_picker.h"
#include "../camera.h"
#include "../engine.h"

namespace vox {
namespace picker {
Camera* FramebufferPicker::camera() {
    return _camera;
}

void FramebufferPicker::setCamera(Camera* value) {
    if (_camera != value) {
        _camera = value;
        auto pass = std::make_unique<ColorRenderPass>("ColorRenderTarget_FBP", -1, colorRenderTarget, Layer::Nothing, engine());
        colorRenderPass = pass.get();
        _camera->addRenderPass(std::move(pass));
    }
}

FramebufferPicker::FramebufferPicker(Entity* entity):
Script(entity) {
    colorRenderTarget = [[MTLRenderPassDescriptor alloc] init];
    MTLTextureDescriptor* descriptor = [[MTLTextureDescriptor alloc]init];
    descriptor.width = 1024;
    descriptor.height = 1024;
    descriptor.pixelFormat = MTLPixelFormatRGBA8Uint;
    colorRenderTarget.colorAttachments[0].texture = [engine()->_hardwareRenderer.device newTextureWithDescriptor:descriptor];
}

void FramebufferPicker::setPickFunctor(std::function<void(Renderer*, MeshPtr)> func) {
    colorRenderPass->setPickFunctor(func);
}

void FramebufferPicker::pick(float offsetX, float offsetY) {
    if (enabled()) {
        _needPick = true;
        _pickPos = math::Float2(offsetX, offsetY);
    }
}

void FramebufferPicker::onUpdate(float deltaTime) {
    if (enabled() && _needPick) {
        colorRenderPass->pick(_pickPos);
        _needPick = false;
    }
}

void FramebufferPicker::onDestroy() {
    if (!_camera->destroyed()) {
        _camera->removeRenderPass(colorRenderPass);
    }
}

}
}
