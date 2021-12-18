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
        auto pass = std::make_unique<ColorRenderPass>("ColorRenderTarget_FBP", -1, colorRenderTarget, Layer::Everything, engine());
        colorRenderPass = pass.get();
        _camera->addRenderPass(std::move(pass));
    }
}

FramebufferPicker::FramebufferPicker(Entity* entity):
Script(entity) {
    metalResourceLoader = entity->engine()->resourceLoader();
    auto createFrameBuffer = [&](GLFWwindow* window, int width, int height){
        int buffer_width, buffer_height;
        glfwGetFramebufferSize(window, &buffer_width, &buffer_height);

        colorRenderTarget.colorAttachments[0].texture =
        metalResourceLoader->buildTexture(buffer_width, buffer_height, MTLPixelFormatBGRA8Unorm,
                                          MTLTextureUsageRenderTarget, MTLStorageModeManaged);
        colorRenderTarget.depthAttachment.texture =
        metalResourceLoader->buildTexture(buffer_width, buffer_height, MTLPixelFormatDepth32Float);
    };
    
    colorRenderTarget = [[MTLRenderPassDescriptor alloc] init];
    createFrameBuffer(_engine->canvas()->handle(), 0, 0);
    Canvas::resize_callbacks.push_back(createFrameBuffer);
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

void FramebufferPicker::onEndFrame() {
    if (_camera) {
        colorRenderPass->execute(_camera);
    }
}

void FramebufferPicker::onDestroy() {
    if (!_camera->destroyed()) {
        _camera->removeRenderPass(colorRenderPass);
    }
}

}
}
