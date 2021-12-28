//
//  mesh_buffer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "mesh_buffer.h"

namespace vox {
MeshBuffer::MeshBuffer(id <MTLBuffer> buffer, size_t length, MDLMeshBufferType type, size_t offset) :
buffer(buffer),
length(length),
type(type),
offset(offset) {
}

MeshBuffer::MeshBuffer(const MeshBuffer &buffer) :
buffer(buffer.buffer),
length(buffer.length),
type(buffer.type),
offset(buffer.offset) {
}

MeshBuffer
MeshBuffer::operator=(const MeshBuffer &buffer) {
    return MeshBuffer(buffer.buffer, buffer.length, buffer.type, buffer.offset);
}

}
