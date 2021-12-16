//
//  gpu_skinned_mesh_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/16.
//

#include "gpu_skinned_mesh_renderer.h"
#include "../entity.h"

namespace vox {
GPUSkinnedMeshRenderer::GPUSkinnedMeshRenderer(Entity* entity):
MeshRenderer(entity) {}

GPUSkinnedMeshRenderer::SkinPtr GPUSkinnedMeshRenderer::skin() {
    return _skin;
}

void GPUSkinnedMeshRenderer::setSkin(const SkinPtr& skin) {
    _skin = skin;
}

void GPUSkinnedMeshRenderer::update(float deltaTime) {
    auto m = entity()->transform->worldMatrix();
    if (_skin) {
        if (!_hasInitJoints) {
          _initJoints();
          _hasInitJoints = true;
        }
        
        // Update join matrices
        auto inverseTransform = invert(m);
        for (size_t i = 0; i < _skin->joints.size(); i++) {
            auto jointNode = _skin->joints[i];
            auto jointMat = jointNode->transform->worldMatrix() * _skin->inverseBindMatrices[i];
            jointMat = inverseTransform * jointMat;
            jointMatrix[i] = jointMat;
        }
    }
}

void GPUSkinnedMeshRenderer::_initJoints() {
    auto jointcount = _skin->joints.size();
}


}
