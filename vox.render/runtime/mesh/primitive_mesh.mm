//
//  primitive_mesh.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "primitive_mesh.h"
#include "../engine.h"

namespace vox {
ModelMeshPtr PrimitiveMesh::createSphere(const EnginePtr& engine,
                                         float radius,
                                         float segments,
                                         bool noLongerAccessible) {
    return nullptr;
}

ModelMeshPtr PrimitiveMesh::createCuboid(const EnginePtr& engine,
                                         float width,
                                         float height,
                                         float depth,
                                         bool noLongerAccessible) {
    return nullptr;
}


ModelMeshPtr PrimitiveMesh::createPlane(const EnginePtr& engine,
                                        float width,
                                        float height,
                                        size_t horizontalSegments,
                                        size_t verticalSegments,
                                        bool noLongerAccessible){
    return nullptr;
}

ModelMeshPtr PrimitiveMesh::createCylinder(const EnginePtr& engine,
                                           float radiusTop,
                                           float radiusBottom,
                                           float height,
                                           size_t radialSegments,
                                           size_t heightSegments,
                                           bool noLongerAccessible) {
    return nullptr;
}

ModelMeshPtr PrimitiveMesh::createTorus(const EnginePtr& engine,
                                        float radius,
                                        float tubeRadius,
                                        size_t radialSegments,
                                        size_t tubularSegments,
                                        float arc,
                                        bool noLongerAccessible) {
    return nullptr;
}

ModelMeshPtr PrimitiveMesh::createCone(const EnginePtr& engine,
                                       float radius,
                                       float height,
                                       size_t radialSegments,
                                       size_t heightSegments,
                                       bool noLongerAccessible) {
    return nullptr;
}

ModelMeshPtr PrimitiveMesh::createCapsule(const EnginePtr& engine,
                                          float radius,
                                          float height,
                                          size_t radialSegments,
                                          size_t heightSegments,
                                          bool noLongerAccessible) {
    return nullptr;
}

void PrimitiveMesh::_createCapsuleCap(float radius,
                                      float height,
                                      size_t radialSegments,
                                      float capAlphaRange,
                                      size_t offset,
                                      size_t posIndex,
                                      std::vector<Float3>& positions,
                                      std::vector<Float3>& normals,
                                      std::vector<Float2>& uvs,
                                      std::vector<uint32_t>& indices,
                                      size_t indicesOffset) {
    
}

void PrimitiveMesh::_initialize(const EnginePtr& engine,
                                const ModelMeshPtr& mesh,
                                const std::vector<Float3>& positions,
                                const std::vector<Float3>& normals,
                                std::vector<Float2>& uvs,
                                const std::vector<uint32_t>& indices,
                                bool noLongerAccessible) {
    mesh->setPositions(positions);
    mesh->setNormals(normals);
    mesh->setUVs(uvs);
    
    mesh->uploadData(noLongerAccessible);
    const auto indexBuffer = [engine->_hardwareRenderer.device newBufferWithBytes:indices.data()
                                                                           length:indices.size() * sizeof(uint32_t)
                                                                          options:MTLResourceStorageModeShared];
    
    mesh->addSubMesh(MeshBuffer(indexBuffer, indices.size() * sizeof(uint32_t), MDLMeshBufferTypeIndex),
                     MTLIndexTypeUInt32, indices.size(), MTLPrimitiveTypeTriangle);
}

}
