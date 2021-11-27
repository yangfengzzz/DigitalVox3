//
//  mesh_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "mesh_renderer.h"
#include "../graphics/mesh.h"

namespace vox {
void MeshRenderer::setMesh(const MeshPtr& newValue) {
    auto& lastMesh = _mesh;
    if (lastMesh != newValue) {
        if (lastMesh != nullptr) {
            _meshUpdateFlag->destroy();
        }
        if (newValue != nullptr) {
            _meshUpdateFlag = newValue->registerUpdateFlag();
        }
        _mesh = newValue;
    }
}

MeshPtr MeshRenderer::mesh() {
    return _mesh;
}

void MeshRenderer::_render(Camera* camera) {
    
}

void MeshRenderer::_onDestroy() {
    
}

void MeshRenderer::_updateBounds(const BoundingBox& worldBounds) {
    
}

}
