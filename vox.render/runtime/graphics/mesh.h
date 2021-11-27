//
//  mesh.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef mesh_hpp
#define mesh_hpp

#import <Metal/Metal.h>
#include <string>
#include <vector>
#include "submesh.h"
#include "maths/bounding_box.h"
#include "../updateFlag_manager.h"
#include "../engine_object.h"

namespace vox {
using namespace math;

class Mesh : public EngineObject {
public:
    /// Create mesh.
    /// - Parameters:
    ///   - engine: Engine
    ///   - name: Mesh name
    Mesh(EnginePtr engine, std::string name = "");
    
    /// Add sub-mesh, each sub-mesh can correspond to an independent material.
    /// - Parameter subMesh: Start drawing offset, if the index buffer is set, it means the offset in the index buffer, if not set, it means the offset in the vertex buffer
    /// - Returns: Sub-mesh
    void addSubMesh(SubMesh subMesh);
    
    /// Add sub-mesh, each sub-mesh can correspond to an independent material.
    /// - Parameters:
    ///   - start: Start drawing offset, if the index buffer is set, it means the offset in the index buffer, if not set, it means the offset in the vertex buffer
    ///   - count: Drawing count, if the index buffer is set, it means the count in the index buffer, if not set, it means the count in the vertex buffer
    ///   - topology: Drawing topology, default is MeshTopology.Triangles
    /// - Returns: Sub-mesh
    void addSubMesh(MeshBuffer indexBuffer, MTLIndexType indexType,
                    size_t indexCount = 0, MTLPrimitiveType topology = MTLPrimitiveTypeTriangle);
    
    /// Clear all sub-mesh.
    void clearSubMesh();
    
    /// Register update flag, update flag will be true if the vertex element changes.
    /// - Returns: Update flag
    std::unique_ptr<UpdateFlag> registerUpdateFlag();
    
    void _setVertexBuffer(int index, MeshBuffer buffer);
    
private:
    /// Name.
    std::string name;
    /// The bounding volume of the mesh.
    BoundingBox bounds = BoundingBox();

    std::vector<MeshBuffer> _vertexBuffer;
    size_t _vertexCount = 0;
    MDLVertexDescriptor* _vertexDescriptor = nullptr;
    std::vector<SubMesh> _subMeshes;

    size_t _instanceCount;
    UpdateFlagManager _updateFlagManager = UpdateFlagManager();
};

}

#endif /* mesh_hpp */