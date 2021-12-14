//
//  particle_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/14.
//

#include "particle_renderer.h"
#include "../engine.h"
#include "../camera.h"
#include "../mesh/buffer_mesh.h"
#include <MetalKit/MetalKit.h>

namespace vox {
ParticleRenderer::ParticleRenderer(Entity* entity):
Renderer(entity) {
    _particleSystemData = std::make_shared<geometry::ParticleSystemData3>();
    _particleSystemData->setRadius(1.0e-3);
    _particleSystemData->setMass(1.0e-3);
}

void ParticleRenderer::setParticleSystemSolver(const geometry::ParticleSystemSolver3Ptr solver) {
    _particleSolver = solver;
    solver->setParticleSystemData(_particleSystemData);
}

void ParticleRenderer::update(float deltaTime) {
    if (_particleSolver) {
        _particleSolver->advanceSingleFrame();
    }
    
    auto position = _particleSystemData->positions();
    const auto n_position = position.length();
    bool shouldResize = _numberOfVertex != n_position;
    if (shouldResize) {
        _renderRelatedInfo.resize(n_position*4);
        for (size_t i = 0; i < _renderRelatedInfo.size(); i += 4) {
            _renderRelatedInfo[i] = 0.5;
            _renderRelatedInfo[i+1] = 0.2;
            _renderRelatedInfo[i+2] = 0.3;
            _renderRelatedInfo[i+3] = 0.5;
        }
    }
}

void ParticleRenderer::_render(Camera* camera) {
    auto render_mesh = _createMesh();
    auto& subMeshes = render_mesh->_subMeshes;
    auto& renderPipeline = camera->_renderPipeline;
    for (size_t i = 0; i < subMeshes.size(); i++) {
        MaterialPtr material;
        if (i < _materials.size()) {
            material = _materials[i];
        } else {
            material = nullptr;
        }
        if (material != nullptr) {
            RenderElement element(this, render_mesh, &subMeshes[i], material);
            renderPipeline.pushPrimitive(element);
        }
    }
}

void ParticleRenderer::_updateBounds(BoundingBox& worldBounds) {
    worldBounds.min = Float3(-10, -10, -10);
    worldBounds.max = Float3(10, 10, 10);
}

MeshPtr ParticleRenderer::_createMesh() {
    auto device = engine()->_hardwareRenderer.device;
    
    auto position = _particleSystemData->positions();
    const auto n_position = position.length();
    bool shouldResize = _numberOfVertex != n_position;
    if (_vertexBuffers == nullptr || shouldResize) {
        _vertexBuffers = [device newBufferWithBytes:position.data()
                                             length:n_position * sizeof(float)
                                            options:NULL];
        _numberOfVertex = position.length();
    } else {
        memcpy([_vertexBuffers contents], position.data(),n_position * sizeof(float));
    }
    
    if (_indexBuffers == nullptr || shouldResize) {
        geometry::Array1<uint32_t> itemIndices(n_position);
        std::iota(std::begin(itemIndices), std::end(itemIndices), 0);
        
        _indexBuffers = [device newBufferWithBytes:itemIndices.data()
                                            length:n_position * sizeof(uint32_t)
                                           options:NULL];
    }
    
    if (_renderBuffers == nullptr || shouldResize) {
        _renderBuffers = [device newBufferWithBytes:_renderRelatedInfo.data()
                                             length:_renderRelatedInfo.size() * sizeof(float)
                                            options:NULL];
    } else {
        memcpy([_renderBuffers contents], _renderRelatedInfo.data(), _renderRelatedInfo.size() * sizeof(float));
    }
    
    MDLVertexDescriptor *vertexDescriptor = [[MDLVertexDescriptor alloc] init];
    vertexDescriptor.attributes[0] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributePosition
                                                                       format:MDLVertexFormatFloat3 offset:0 bufferIndex:0];
    vertexDescriptor.attributes[1] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeColor
                                                                       format:MDLVertexFormatFloat4 offset:0 bufferIndex:1];
    vertexDescriptor.layouts[0] = [[MDLVertexBufferLayout alloc] initWithStride:sizeof(float) * 3];
    vertexDescriptor.layouts[1] = [[MDLVertexBufferLayout alloc] initWithStride:sizeof(float) * 4];
    
    auto mesh = std::make_shared<BufferMesh>(_engine);
    mesh->setVertexDescriptor(vertexDescriptor);
    mesh->setVertexBufferBinding(_vertexBuffers, 0, 0);
    mesh->setVertexBufferBinding(_renderBuffers, 0, 1);

    mesh->addSubMesh(MeshBuffer(_indexBuffers,
                                n_position * sizeof(uint32_t),
                                MDLMeshBufferTypeIndex),
                     MTLIndexTypeUInt32, n_position, MTLPrimitiveTypePoint);
    
    return mesh;
}

geometry::ParticleSystemData3Ptr &ParticleRenderer::particleSystemData() {
    return _particleSystemData;
}


}
