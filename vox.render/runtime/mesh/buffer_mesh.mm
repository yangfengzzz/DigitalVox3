//
//  buffer_mesh.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#include "buffer_mesh.h"

namespace vox {
BufferMesh::BufferMesh(Engine* engine, const std::string& name):
Mesh(engine, name) {
}

size_t BufferMesh::instanceCount() {
    return _instanceCount;
}

void BufferMesh::setInstanceCount(size_t newValue) {
    _instanceCount = newValue;
}

const std::vector<std::optional<MeshBuffer>>& BufferMesh::vertexBuffer() {
    return _vertexBuffer;
}

MDLVertexDescriptor* BufferMesh::vertexDescriptor() {
    return _vertexDescriptor;
}

void BufferMesh::setVertexDescriptor(MDLVertexDescriptor* descriptor) {
    _vertexDescriptor = descriptor;
}

void BufferMesh::setVertexBuffer(const MeshBuffer& vertexBuffer, size_t index) {
    if (_vertexBuffer.size() <= index) {
        _vertexBuffer.reserve(index + 1);
        for (size_t i = _vertexBuffer.size(); i <= index; i++) {
            _vertexBuffer.push_back(std::nullopt);
        }
    }
    _setVertexBuffer(index, vertexBuffer);
}

void BufferMesh::setVertexBufferBinding(id<MTLBuffer> vertexBuffer, int offset, size_t index) {
    auto binding = MeshBuffer(vertexBuffer, offset, MDLMeshBufferTypeVertex);
    if (_vertexBuffer.size() <= index) {
        _vertexBuffer.reserve(index + 1);
        for (size_t i = _vertexBuffer.size(); i <= index; i++) {
            _vertexBuffer.push_back(std::nullopt);
        }
    }
    _setVertexBuffer(index, binding);
}

void BufferMesh::setVertexBufferBindings(const std::vector<MeshBuffer>& vertexBufferBindings, size_t firstIndex) {
    auto count = vertexBufferBindings.size();
    auto needLength = firstIndex + count;
    if (_vertexBuffer.size() < needLength) {
        _vertexBuffer.reserve(needLength);
        for (size_t i = _vertexBuffer.size(); i < needLength; i++) {
            _vertexBuffer.push_back(std::nullopt);
        }
    }
    for (size_t i = 0; i < count; i++) {
        _setVertexBuffer(firstIndex + i, vertexBufferBindings[i]);
    }
}

}
