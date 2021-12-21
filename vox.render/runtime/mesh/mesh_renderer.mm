//
//  mesh_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "mesh_renderer.h"
#include "../graphics/mesh.h"
#include "../entity.h"
#include "../camera.h"

namespace vox {
MeshRenderer::MeshRenderer(Entity* entity):
Renderer(entity) {
    
}

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
    if (_mesh != nullptr) {
        if (_meshUpdateFlag->flag) {
            const auto& vertexDescriptor = _mesh->vertexDescriptor();

            shaderData.disableMacro(HAS_UV);
            shaderData.disableMacro(HAS_NORMAL);
            shaderData.disableMacro(HAS_TANGENT);
            shaderData.disableMacro(HAS_VERTEXCOLOR);
            
            if ([vertexDescriptor attributeNamed:MDLVertexAttributeTextureCoordinate] != nullptr) {
                shaderData.enableMacro(HAS_UV);
            }
            if ([vertexDescriptor attributeNamed:MDLVertexAttributeNormal] != nullptr) {
                shaderData.enableMacro(HAS_NORMAL);
            }
            if ([vertexDescriptor attributeNamed:MDLVertexAttributeTangent] != nullptr) {
                shaderData.enableMacro(HAS_TANGENT);
            }
            if ([vertexDescriptor attributeNamed:MDLVertexAttributeColor] != nullptr) {
                shaderData.enableMacro(HAS_VERTEXCOLOR);
            }
            _meshUpdateFlag->flag = false;
        }

        auto& subMeshes = _mesh->subMeshes();
        for (size_t i = 0; i < subMeshes.size(); i++) {
            MaterialPtr material;
            if (i < _materials.size()) {
                material = _materials[i];
            } else {
                material = nullptr;
            }
            if (material != nullptr) {
                RenderElement element(this, _mesh, &subMeshes[i], material);
                camera->pushPrimitive(element);
            }
        }
    } else {
        assert(false && "mesh is nullptr.");
    }
}

void MeshRenderer::_onDestroy() {
    Renderer::_onDestroy();
    _mesh = nullptr;
}

void MeshRenderer::_updateBounds(BoundingBox& worldBounds) {
    if (_mesh != nullptr) {
        const auto localBounds = _mesh->bounds;
        const auto worldMatrix = _entity->transform->worldMatrix();
        worldBounds = transform(localBounds, worldMatrix);
    } else {
        worldBounds.min = Float3(0, 0, 0);
        worldBounds.max = Float3(0, 0, 0);
    }
}

}
