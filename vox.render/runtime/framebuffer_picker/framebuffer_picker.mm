//
//  framebuffer_picker.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#include "framebuffer_picker.h"
#include "../camera.h"

namespace vox {
namespace picker {
Camera* FramebufferPicker::camera() {
    return _camera;
}

void FramebufferPicker::setCamera(Camera* value) {
    if (_camera != value) {
        _camera = value;
    }
}

FramebufferPicker::FramebufferPicker(Entity* entity):
Script(entity) {
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
