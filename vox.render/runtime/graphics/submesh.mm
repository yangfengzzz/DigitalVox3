//
//  submesh.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "submesh.h"

namespace vox {
SubMesh::SubMesh(MeshBuffer indexBuffer, MTLIndexType indexType,
                 size_t indexCount, MTLPrimitiveType topology) :
indexBuffer(indexBuffer),
indexType(indexType),
indexCount(indexCount),
topology(topology) {
}

}
