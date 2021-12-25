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
#include <optional>
#include "submesh.h"
#include "maths/bounding_box.h"
#include "../updateFlag_manager.h"
#include "../engine_object.h"

namespace vox {
using namespace math;
/**
 * Mesh.
 */
class Mesh : public EngineObject {
public:
    /** Name. */
    std::string name;
    /** The bounding volume of the mesh. */
    BoundingBox bounds = BoundingBox();
    
    /**
     * Create mesh.
     * @param engine - Engine
     * @param name - Mesh name
     */
    Mesh(Engine* engine, const std::string& name = "");
    
    /**
     * First sub-mesh. Rendered using the first material.
     */
    SubMesh* subMesh(size_t index);
    
    /**
     * A collection of sub-mesh, each sub-mesh can be rendered with an independent material.
     */
    const std::vector<SubMesh>& subMeshes() const;
    
    /**
     * Add sub-mesh, each sub-mesh can correspond to an independent material.
     * @param subMesh - Start drawing offset, if the index buffer is set, it means the offset in the index buffer, if not set, it means the offset in the vertex buffer
     */
    void addSubMesh(SubMesh subMesh);
    
    /**
     * Add sub-mesh, each sub-mesh can correspond to an independent material.
     * @param indexBuffer - Index Buffer
     * @param indexType -MTLIndexType
     * @param indexCount - Drawing count, if the index buffer is set, it means the count in the index buffer, if not set, it means the count in the vertex buffer
     * @param topology - Drawing topology, default is MeshTopology.Triangles
     */
    void addSubMesh(MeshBuffer indexBuffer, MTLIndexType indexType,
                    size_t indexCount = 0, MTLPrimitiveType topology = MTLPrimitiveTypeTriangle);
    
    /**
     * Clear all sub-mesh.
     */
    void clearSubMesh();
    
    /**
     * Register update flag, update flag will be true if the vertex element changes.
     * @returns Update flag
     */
    std::unique_ptr<UpdateFlag> registerUpdateFlag();
    
    void _setVertexBuffer(size_t index, MeshBuffer buffer);
    
    MDLVertexDescriptor* vertexDescriptor();
    
protected:
    friend class RenderPipeline;
    friend class ForwardRenderPipeline;
    friend class DeferredRenderPipeline;

    MDLVertexDescriptor* _vertexDescriptor = nullptr;
    std::vector<std::optional<MeshBuffer>> _vertexBuffer;
    std::vector<SubMesh> _subMeshes;
    UpdateFlagManager _updateFlagManager = UpdateFlagManager();

    //MARK: - useless
    size_t _instanceCount;
    size_t _vertexCount = 0;
};

}

#endif /* mesh_hpp */
