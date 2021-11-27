//
//  mesh.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "mesh.h"

namespace vox {
Mesh::Mesh(EnginePtr engine, std::string name):EngineObject(engine), name(name) {
}

void Mesh::addSubMesh(SubMesh subMesh) {
    _subMeshes.push_back(subMesh);
}

void Mesh::addSubMesh(MeshBuffer indexBuffer, MTLIndexType indexType,
                      size_t indexCount, MTLPrimitiveType topology) {
    const auto startOrSubMesh = SubMesh(indexBuffer, indexType, indexCount, topology);
    _subMeshes.push_back(startOrSubMesh);
}

void Mesh::clearSubMesh() {
    _subMeshes.clear();
}

std::unique_ptr<UpdateFlag> Mesh::registerUpdateFlag() {
    return _updateFlagManager.registration();
}

void Mesh::_setVertexBuffer(int index, MeshBuffer buffer) {
    _vertexBuffer.insert(_vertexBuffer.begin() + index, buffer);
}

}
