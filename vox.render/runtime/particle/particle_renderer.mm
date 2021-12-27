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
#include <random>

namespace vox {
ParticleRenderer::ParticleRenderer(Entity* entity):
Renderer(entity) {
    metalResourceLoader = entity->engine()->resourceLoader();
    
    _particleSystemData = std::make_shared<geometry::ParticleSystemData3>();
    _particleSystemData->setRadius(1.0e-3);
    _particleSystemData->setMass(1.0e-3);
}

void ParticleRenderer::setParticleSystemSolver(const geometry::ParticleSystemSolver3Ptr solver) {
    _particleSolver = solver;
    solver->emitter()->setTarget(_particleSystemData);
    solver->setParticleSystemData(_particleSystemData);
}

void ParticleRenderer::update(float deltaTime) {
    if (_particleSolver) {
        frame.advance();
        _particleSolver->update(frame);
        
        if (frame.index > 1000) {
            setEnabled(false);
        }
    }
    
    std::default_random_engine e{};
    std::uniform_real_distribution<float> u = std::uniform_real_distribution<float>(-0.5, 0.5);
    
    auto position = _particleSystemData->positions();
    const auto n_position = position.length();
    bool shouldResize = _numberOfVertex != n_position;
    if (shouldResize) {
        _renderRelatedInfo.resize(n_position*4);
        for (size_t i = 0; i < _renderRelatedInfo.size(); i += 4) {
            _renderRelatedInfo[i] = u(e);
            _renderRelatedInfo[i+1] = u(e);
            _renderRelatedInfo[i+2] = u(e);
            _renderRelatedInfo[i+3] = 1.0;
        }
    }
}

void ParticleRenderer::_render(std::vector<RenderElement>& opaqueQueue,
                               std::vector<RenderElement>& alphaTestQueue,
                               std::vector<RenderElement>& transparentQueue) {
    auto render_mesh = _createMesh();
    auto& subMeshes = render_mesh->subMeshes();
    for (size_t i = 0; i < subMeshes.size(); i++) {
        MaterialPtr material;
        if (i < _materials.size()) {
            material = _materials[i];
        } else {
            material = nullptr;
        }
        if (material != nullptr) {
            pushPrimitive(RenderElement(this, render_mesh, &subMeshes[i], material),
                          opaqueQueue, alphaTestQueue, transparentQueue);
        }
    }
}

void ParticleRenderer::_updateBounds(BoundingBox& worldBounds) {
    worldBounds.min = Float3(-10, -10, -10);
    worldBounds.max = Float3(10, 10, 10);
}

MeshPtr ParticleRenderer::_createMesh() {
    auto position = _particleSystemData->positions();
    const auto n_position = position.length();
    bool shouldResize = _numberOfVertex != n_position;
    
    std::vector<float> flatData(n_position * 3);
    for (size_t i = 0; i < n_position; i++) {
        flatData[3*i] = position[i].x;
        flatData[3*i+1] = position[i].y;
        flatData[3*i+2] = position[i].z;
    }
    
    if (_vertexBuffers == nullptr || shouldResize) {
        _vertexBuffers = metalResourceLoader->buildBuffer(flatData.data(),
                                                          n_position * sizeof(float) * 3, NULL);
        _numberOfVertex = n_position;
    } else {
        memcpy([_vertexBuffers contents], flatData.data(), n_position * sizeof(float) * 3);
    }
    
    if (_indexBuffers == nullptr || shouldResize) {
        geometry::Array1<uint32_t> itemIndices(n_position);
        std::iota(std::begin(itemIndices), std::end(itemIndices), 0);
        
        _indexBuffers = metalResourceLoader->buildBuffer(itemIndices.data(),
                                                         n_position * sizeof(uint32_t), NULL);
    }
    
    if (_renderBuffers == nullptr || shouldResize) {
        _renderBuffers = metalResourceLoader->buildBuffer(_renderRelatedInfo.data(),
                                                          _renderRelatedInfo.size() * sizeof(float), NULL);
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
