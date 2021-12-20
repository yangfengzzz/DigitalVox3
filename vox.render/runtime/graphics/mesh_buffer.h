//
//  mesh_buffer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef mesh_buffer_hpp
#define mesh_buffer_hpp

#import <Metal/Metal.h>
#import <ModelIO/ModelIO.h>

namespace vox {
struct MeshBuffer {
    size_t length() const;
    
    id <MTLBuffer> buffer() const;
    
    size_t offset() const;
    
    MDLMeshBufferType type() const;
    
    /// Create vertex buffer.
    /// - Parameters:
    ///   - buffer: Vertex buffer
    ///   - length: Vertex buffer length
    ///   - offset: Vertex buffer offset
    MeshBuffer(id <MTLBuffer> buffer, size_t length, MDLMeshBufferType type, size_t offset = 0);
    
private:
    size_t _length;
    id <MTLBuffer> _buffer;
    size_t _offset;
    MDLMeshBufferType _type;
};

}

#endif /* mesh_buffer_hpp */
