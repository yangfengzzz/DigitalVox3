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
/**
 * Sub-mesh, mainly contains drawing information.
 */
struct SubMesh {
    /** Index buffer. */
    const MeshBuffer indexBuffer;
    /** Type of index buffer. */
    const MTLIndexType indexType;
    /** Drawing count. */
    const size_t indexCount;
    /** Drawing topology. */
    const MTLPrimitiveType topology;
    
    /**
     * Create a sub-mesh.
     * @param indexBuffer - Index Buffer
     * @param indexType - Index Type
     * @param indexCount - Drawing count
     * @param topology - Drawing topology
     */
    SubMesh(MeshBuffer indexBuffer, MTLIndexType indexType,
            size_t indexCount = 0, MTLPrimitiveType topology = MTLPrimitiveTypeTriangle);
};

}

#endif /* submesh_hpp */
