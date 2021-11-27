//
//  mesh_buffer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "mesh_buffer.h"

namespace vox {
MeshBuffer::MeshBuffer(id <MTLBuffer> buffer, size_t length, MDLMeshBufferType type, size_t offset) :
_buffer(buffer),
_length(length),
_type(type),
_offset(offset) {
}

size_t MeshBuffer::length() {
    return _length;
}

id <MTLBuffer> MeshBuffer::buffer() {
    return _buffer;
}

size_t MeshBuffer::offset() {
    return _offset;
}

MDLMeshBufferType MeshBuffer::type() {
    return _type;
}

}