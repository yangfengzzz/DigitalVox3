//
//  submesh.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef submesh_hpp
#define submesh_hpp

#include "mesh_buffer.h"

namespace vox {
/// Sub-mesh, mainly contains drawing information.
struct SubMesh {
    /// Drawing topology.
    MTLPrimitiveType topology;
    /// Type of index buffer
    MTLIndexType indexType;
    /// IndexBuffer
    MeshBuffer indexBuffer;
    /// Drawing count.
    size_t indexCount;
    
    
    /// Create a sub-mesh.
    /// - Parameters:
    ///   - indexBuffer: Index Buffer
    ///   - indexType: Index Type
    ///   - indexCount: Drawing count
    ///   - topology: Drawing topology
    SubMesh(MeshBuffer indexBuffer, MTLIndexType indexType,
            int indexCount = 0, MTLPrimitiveType topology = MTLPrimitiveTypeTriangle);
};

}

#endif /* submesh_hpp */
