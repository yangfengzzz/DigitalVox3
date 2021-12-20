//
//  render_context.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "render_context.h"
#include "../camera.h"

namespace vox {
Camera* RenderContext::camera() {
    return _camera;
}

const Camera* RenderContext::camera() const {
    return _camera;
}

const Scene* RenderContext::scene() const {
    return _scene;
}

const Matrix RenderContext::viewProjectMatrix() const {
    return _viewProjectMatrix;
}

void RenderContext::resetContext(Scene* scene, Camera* camera) {
    _scene = scene;
    _camera = camera;
    _viewProjectMatrix = camera->projectionMatrix() * camera->viewMatrix();
}

}
