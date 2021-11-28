//
//  buffer_mesh.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#include "buffer_mesh.h"

namespace vox {
size_t BufferMesh::instanceCount() {
    return _instanceCount;
}

void BufferMesh::setInstanceCount(size_t newValue) {
    _instanceCount = newValue;
}

const std::vector<MeshBuffer>& BufferMesh::vertexBuffer() {
    return _vertexBuffer;
}

MDLVertexDescriptor* BufferMesh::vertexDescriptor() {
    return _vertexDescriptor;
}

void BufferMesh::setVertexDescriptor(MDLVertexDescriptor* descriptor) {
    _vertexDescriptor = descriptor;
}

}
