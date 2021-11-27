//
//  model_mesh.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef model_mesh_hpp
#define model_mesh_hpp

#include "../graphics/mesh.h"
#include "maths/vec_float.h"
#include "maths/color.h"
#include <Metal/Metal.h>

namespace vox {
using namespace math;

enum ValueChanged {
    Position = 0x1,
    Normal = 0x2,
    Color = 0x4,
    Tangent = 0x8,
    BoneWeight = 0x10,
    BoneIndex = 0x20,
    UV = 0x40,
    UV1 = 0x80,
    UV2 = 0x100,
    UV3 = 0x200,
    UV4 = 0x400,
    UV5 = 0x800,
    UV6 = 0x1000,
    UV7 = 0x2000,
    BlendShape = 0x4000,
    All = 0xffff
};

const MDLVertexAttribute* POSITION_VERTEX_DESCRIPTOR =
[[MDLVertexAttribute alloc]initWithName:MDLVertexAttributePosition
                                 format:MDLVertexFormatFloat3
                                 offset:0 bufferIndex:0];

class ModelMesh: Mesh {
public:
    /// Whether to access data of the mesh.
    bool accessible();
    
    /// Vertex count of current mesh.
    size_t vertexCount();
    
    /// Create a model mesh.
    /// - Parameters:
    ///   - engine: Engine to which the mesh belongs
    ///   - name: Mesh name
    ModelMesh(const EnginePtr& engine, const std::string& name = "");
    
public:
    /// Set positions for the mesh.
    /// - Parameter positions: The positions for the mesh.
    void setPositions(const std::vector<Float3>& positions);
    
    /// Get positions for the mesh.
    /// - Remark: Please call the setPositions() method after modification to ensure that the modification takes effect.
    const std::vector<Float3>& positions();
    
    /// Set per-vertex normals for the mesh.
    /// - Parameter normals: The normals for the mesh.
    void setNormals(const std::vector<Float3>& normals);
    
    /// Get normals for the mesh.
    /// - Remark: Please call the setNormals() method after modification to ensure that the modification takes effect.
    const std::vector<Float3>& normals();
    
    /// Set per-vertex colors for the mesh.
    /// - Parameter colors: The colors for the mesh.
    void setColors(const std::vector<math::Color>& colors);
    
    /// Get colors for the mesh.
    /// - Remark: Please call the setColors() method after modification to ensure that the modification takes effect.
    const std::vector<math::Color>& colors();
    
    /// Set per-vertex tangents for the mesh.
    /// - Parameter tangents: The tangents for the mesh.
    void setTangents(const std::vector<Float4>& tangents);
    
    /// Get tangents for the mesh.
    /// - Remark: Please call the setTangents() method after modification to ensure that the modification takes effect.
    const std::vector<Float4>& tangents();
    
    /// Set per-vertex uv for the mesh by channelIndex.
    /// - Parameters:
    ///   - uv: The uv for the mesh.
    ///   - channelIndex: The index of uv channels, in [0 ~ 7] range.
    void setUVs(const std::vector<Float2>& uv, int channelIndex = 0);
    
    /// Get uv for the mesh by channelIndex.
    /// - Parameter channelIndex: The index of uv channels, in [0 ~ 7] range.
    /// - Remark: Please call the setUV() method after modification to ensure that the modification takes effect.
    const std::vector<Float2>& uvs(int channelIndex = 0);
    
    /// Upload Mesh Data to the graphics API.
    /// - Parameter noLongerAccessible: Whether to access data later. If true, you'll never access data anymore (free memory cache)
    void uploadData(bool noLongerAccessible);
    
private:
    MDLVertexDescriptor* _updateVertexDescriptor();
    
    void _updateVertices(std::vector<float>& vertices);
    
    void _releaseCache();
    
    bool _hasBlendShape = false;
    bool _useBlendShapeNormal = false;
    bool _useBlendShapeTangent = false;
    id<MTLTexture> _blendShapeTexture;
    
    bool _accessible = true;
    std::vector<float> _verticesFloat32;
    std::vector<uint8_t> _verticesUint8;
    bool _vertexSlotChanged = true;
    int _vertexChangeFlag;
    size_t _elementCount;
    
    std::vector<Float3> _positions;
    std::vector<Float3> _normals;
    std::vector<math::Color> _colors;
    std::vector<Float4> _tangents;
    std::vector<Float2> _uv;
    std::vector<Float2> _uv1;
    std::vector<Float2> _uv2;
    std::vector<Float2> _uv3;
    std::vector<Float2> _uv4;
    std::vector<Float2> _uv5;
    std::vector<Float2> _uv6;
    std::vector<Float2> _uv7;
    std::vector<Float4> _boneWeights;
    std::vector<Float4> _boneIndices;
};

}


#endif /* model_mesh_hpp */
