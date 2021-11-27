//
//  render_context.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "render_context.h"
#include "../camera.h"

namespace vox {
void RenderContext::_setContext(Camera* camera) {
    _camera = camera;
    _viewProjectMatrix = camera->projectionMatrix() * camera->viewMatrix();
}

}
