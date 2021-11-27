//
//  renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "renderer.h"
#include "entity.h"
#include "camera.h"

namespace vox {
ShaderProperty Renderer::_localMatrixProperty = Shader::getPropertyByName("u_localMat");
ShaderProperty Renderer::_worldMatrixProperty = Shader::getPropertyByName("u_modelMat");
ShaderProperty Renderer::_mvMatrixProperty = Shader::getPropertyByName("u_MVMat");
ShaderProperty Renderer::_mvpMatrixProperty = Shader::getPropertyByName("u_MVPMat");
ShaderProperty Renderer::_mvInvMatrixProperty = Shader::getPropertyByName("u_MVInvMat");
ShaderProperty Renderer::_normalMatrixProperty = Shader::getPropertyByName("u_normalMat");

size_t Renderer::materialCount() {
    return _materials.size();
}

BoundingBox Renderer::bounds() {
    auto& changeFlag = _transformChangeFlag;
    if (changeFlag->flag) {
        _updateBounds(_bounds);
        changeFlag->flag = false;
    }
    return _bounds;
}

Renderer::Renderer(Entity* entity):
Component(entity),
_transformChangeFlag(entity->transform->registerWorldChangeFlag()) {
    _overrideUpdate = true;
}

void Renderer::_onEnable()  {
}

void Renderer::_onDisable()  {
}

void Renderer::_onDestroy()  {
    auto& flag = _transformChangeFlag;
    if (flag != nullptr) {
        flag->destroy();
        _transformChangeFlag.reset();
    }
}

MaterialPtr Renderer::getInstanceMaterial(size_t index) {
    const auto& materials = _materials;
    if (materials.size() > index) {
        const auto& material = materials[index];
        if (material != nullptr) {
            if (_materialsInstanced[index]) {
                return material;
            } else {
                return _createInstanceMaterial(material, index);
            }
        }
    }
    return nullptr;
}

MaterialPtr Renderer::getMaterial(size_t index) {
    return _materials[index];
}

void Renderer::setMaterial(MaterialPtr material) {
    size_t index = 0;

    if (index >= _materials.size()) {
        _materials.reserve(index + 1);
        for (size_t i = _materials.size(); i < index; i++) {
            _materials.push_back(nullptr);
        }
    }

    const auto& internalMaterial = _materials[index];
    if (internalMaterial != material) {
        _materials[index] = material;
        if (index < _materialsInstanced.size()) {
            _materialsInstanced[index] = false;
        }
    }
}

void Renderer::setMaterial(size_t index, MaterialPtr material) {
    if (index >= _materials.size()) {
        _materials.reserve(index + 1);
        for (size_t i = _materials.size(); i < index; i++) {
            _materials.push_back(nullptr);
        }
    }

    const auto& internalMaterial = _materials[index];
    if (internalMaterial != material) {
        _materials[index] = material;
        if (index < _materialsInstanced.size()) {
            _materialsInstanced[index] = false;
        }
    }
}

std::vector<MaterialPtr> Renderer::getInstanceMaterials() {
    for (size_t i = 0; i < _materials.size(); i++) {
        if (!_materialsInstanced[i]) {
            _createInstanceMaterial(_materials[i], i);
        }
    }
    return _materials;
}

std::vector<MaterialPtr> Renderer::getMaterials() {
    return _materials;
}

void Renderer::setMaterials(const std::vector<MaterialPtr>& materials) {
    size_t count = materials.size();
    if (_materials.size() != count) {
        _materials.reserve(count);
        for (size_t i = _materials.size(); i < count; i++) {
            _materials.push_back(nullptr);
        }
    }
    if (_materialsInstanced.size() != 0) {
        _materialsInstanced.clear();
    }

    for (size_t i = 0; i < count; i++) {
        const auto& internalMaterial = _materials[i];
        const auto& material = materials[i];
        if (internalMaterial != material) {
            _materials[i] = material;
        }
    }
}

void Renderer::_updateShaderData(const RenderContext& context) {
    Matrix worldMatrix = entity()->transform->worldMatrix();
    _mvMatrix = context._camera->viewMatrix() * worldMatrix;
    _mvpMatrix = context._viewProjectMatrix * worldMatrix;
    _mvInvMatrix = invert(_mvMatrix);
    _normalMatrix = invert(_normalMatrix);
    _normalMatrix = transpose(_normalMatrix);

    shaderData.setData(Renderer::_localMatrixProperty, entity()->transform->localMatrix());
    shaderData.setData(Renderer::_worldMatrixProperty, worldMatrix);
    shaderData.setData(Renderer::_mvMatrixProperty, _mvMatrix);
    shaderData.setData(Renderer::_mvpMatrixProperty, _mvpMatrix);
    shaderData.setData(Renderer::_mvInvMatrixProperty, _mvInvMatrix);
    shaderData.setData(Renderer::_normalMatrixProperty, _normalMatrix);
}

MaterialPtr Renderer::_createInstanceMaterial(const MaterialPtr& material, size_t index) {
    return nullptr;
}

}