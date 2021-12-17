//
//  gpu_skinned_mesh_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/16.
//

#include "gpu_skinned_mesh_renderer.h"
#include "../entity.h"
#include "../engine.h"

namespace vox {
ShaderProperty GPUSkinnedMeshRenderer::_jointMatrixProperty = Shader::createProperty("u_jointMatrix", ShaderDataGroup::Renderer);
GPUSkinnedMeshRenderer::GPUSkinnedMeshRenderer(Entity* entity):
MeshRenderer(entity) {}

GPUSkinnedMeshRenderer::SkinPtr GPUSkinnedMeshRenderer::skin() {
    return _skin;
}

void GPUSkinnedMeshRenderer::setSkin(const SkinPtr& skin) {
    _skin = skin;
}

void GPUSkinnedMeshRenderer::update(float deltaTime) {
    if (_skin) {
        if (!_hasInitJoints) {
            _initJoints();
            _hasInitJoints = true;
        }
        
        // Update join matrices
        auto m = entity()->transform->worldMatrix();
        auto inverseTransform = invert(m);
        for (size_t i = 0; i < _skin->joints.size(); i++) {
            auto jointNode = _skin->joints[i];
            auto jointMat = jointNode->transform->worldMatrix() * _skin->inverseBindMatrices[i];
            jointMat = inverseTransform * jointMat;
            std::copy(jointMat.elements.begin(), jointMat.elements.end(), jointMatrix.data() + i * 16);
        }
        memcpy([matrixPalette contents], jointMatrix.data(), jointMatrix.size() * sizeof(float));
        shaderData.setData(_jointMatrixProperty, matrixPalette);
    }
}

void GPUSkinnedMeshRenderer::_initJoints() {
    jointMatrix.resize(_skin->joints.size() * 16);
    matrixPalette = [engine()->_hardwareRenderer.device newBufferWithLength:jointMatrix.size() * sizeof(float) options:NULL];
}


}
