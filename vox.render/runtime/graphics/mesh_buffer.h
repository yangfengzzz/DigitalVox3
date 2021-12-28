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
    const size_t length;
    const id <MTLBuffer> buffer;
    const size_t offset;
    const MDLMeshBufferType type;
    
    /**
     * Create mesh buffer.
     * @param buffer - Vertex buffer
     * @param length - Vertex buffer length
     * @param offset - Vertex buffer offset
     */
    MeshBuffer(id <MTLBuffer> buffer, size_t length, MDLMeshBufferType type, size_t offset = 0);
    
    MeshBuffer(const MeshBuffer &buffer);
    
    MeshBuffer operator=(const MeshBuffer &buffer);
};

}

#endif /* mesh_buffer_hpp */
