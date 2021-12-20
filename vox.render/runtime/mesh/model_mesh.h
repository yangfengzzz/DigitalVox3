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

namespace vox {
using namespace math;

struct ValueChanged {
    enum Enum {
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
};

/**
 * Mesh containing common vertex elements of the model.
 */
class ModelMesh: public Mesh {
public:
    /**
     * Whether to access data of the mesh.
     */
    bool accessible();
    
    /**
     * Vertex count of current mesh.
     */
    size_t vertexCount();
    
    /**
     * Create a model mesh.
     * @param engine - Engine to which the mesh belongs
     * @param name - Mesh name
     */
    ModelMesh(Engine* engine, const std::string& name = "");
    
public:
    /**
     * Set positions for the mesh.
     * @param positions - The positions for the mesh.
     */
    void setPositions(const std::vector<Float3>& positions);
    
    /**
     * Get positions for the mesh.
     * @remarks Please call the setPositions() method after modification to ensure that the modification takes effect.
     */
    const std::vector<Float3>& positions();
    
    /**
     * Set per-vertex normals for the mesh.
     * @param normals - The normals for the mesh.
     */
    void setNormals(const std::vector<Float3>& normals);
    
    /**
     * Get normals for the mesh.
     * @remarks Please call the setNormals() method after modification to ensure that the modification takes effect.
     */
    const std::vector<Float3>& normals();
    
    /**
     * Set per-vertex colors for the mesh.
     * @param colors - The colors for the mesh.
     */
    void setColors(const std::vector<math::Color>& colors);
    
    /**
     * Get colors for the mesh.
     * @remarks Please call the setColors() method after modification to ensure that the modification takes effect.
     */
    const std::vector<math::Color>& colors();
    
    /**
     * Set per-vertex tangents for the mesh.
     * @param tangents - The tangents for the mesh.
     */
    void setTangents(const std::vector<Float4>& tangents);
    
    /**
     * Get tangents for the mesh.
     * @remarks Please call the setTangents() method after modification to ensure that the modification takes effect.
     */
    const std::vector<Float4>& tangents();
    
    /**
     * Set per-vertex uv for the mesh by channelIndex.
     * @param uv - The uv for the mesh.
     * @param channelIndex - The index of uv channels, in [0 ~ 7] range.
     */
    void setUVs(const std::vector<Float2>& uv, int channelIndex = 0);
    
    /**
     * Get uv for the mesh by channelIndex.
     * @param channelIndex - The index of uv channels, in [0 ~ 7] range.
     * @remarks Please call the setUV() method after modification to ensure that the modification takes effect.
     */
    const std::vector<Float2>& uvs(int channelIndex = 0);
    
    /**
     * Set indices for the mesh.
     * @param indices - The indices for the mesh.
     */
    void setIndices(const std::vector<uint32_t>& indices);

    /**
     * Get indices for the mesh.
     */
    const std::vector<uint32_t> indices();
    
    /**
     * Upload Mesh Data to the graphics API.
     * @param noLongerAccessible - Whether to access data later. If true, you'll never access data anymore (free memory cache)
     */
    void uploadData(bool noLongerAccessible);
    
private:
    MetalLoaderPtr resourceLoader;
    MDLVertexDescriptor* _updateVertexDescriptor();
    
    void _updateVertices(std::vector<float>& vertices);
    
    void _releaseCache();
    
    bool _hasBlendShape = false;
    bool _useBlendShapeNormal = false;
    bool _useBlendShapeTangent = false;
    id<MTLTexture> _blendShapeTexture;
    
    bool _accessible = true;
    int _vertexChangeFlag;
    size_t _elementCount;
    std::vector<float> _vertices{};
    std::vector<uint32_t> _indices{};
    
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
