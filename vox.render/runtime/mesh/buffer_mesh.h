//
//  buffer_mesh.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#ifndef buffer_mesh_hpp
#define buffer_mesh_hpp

#include "mesh.h"

namespace vox {
/// BufferMesh.
class BufferMesh: public Mesh {
    /// Instanced count, disable instanced drawing when set zero.
    size_t instanceCount();
    void setInstanceCount(size_t newValue);

    /// Vertex buffer collection.
    const std::vector<MeshBuffer>& vertexBuffer();
    
    MDLVertexDescriptor* vertexDescriptor();
    /// Set vertex descriptor.
    /// - Parameter descriptor: Vertex element collection
    void setVertexDescriptor(MDLVertexDescriptor* descriptor);
    
    /// Set vertex buffer binding.
    /// - Parameters:
    ///   - vertexBuffer: Vertex buffer binding
    ///   - index: Vertex buffer index, the default value is 0
    void setVertexBuffer(const MeshBuffer& vertexBuffer, size_t index);
    
    /// Set vertex buffer binding.
    /// - Parameters:
    ///   - vertexBuffer: Vertex buffer
    ///   - offset: Vertex buffer data offset
    ///   - index: Vertex buffer index, the default value is 0
    void setVertexBufferBinding(id<MTLBuffer> vertexBuffer, int offset, size_t index = 0);
    
    /// Set vertex buffer binding.
    /// - Parameters:
    ///   - vertexBufferBindings: Vertex buffer binding
    ///   - firstIndex: First vertex buffer index, the default value is 0
    void setVertexBufferBindings(const std::vector<MeshBuffer>& vertexBufferBindings, size_t firstIndex = 0);
};

}

#endif /* buffer_mesh_hpp */