//
//  fbx_mesh.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#ifndef fbx_mesh_hpp
#define fbx_mesh_hpp

#include "../io/archive.h"
#include "../containers/vector.h"
#include "../maths/simd_math.h"

namespace vox {
namespace offline {
namespace loader {

// Defines a mesh with skinning information (joint indices and weights).
// The mesh is subdivided into parts that group vertices according to their
// number of influencing joints. Triangle indices are shared across mesh parts.
struct Mesh {
    // Number of triangle indices for the mesh.
    int triangle_index_count() const {
        return static_cast<int>(triangle_indices.size());
    }
    
    // Number of vertices for all mesh parts.
    int vertex_count() const {
        int vertex_count = 0;
        for (size_t i = 0; i < parts.size(); ++i) {
            vertex_count += parts[i].vertex_count();
        }
        return vertex_count;
    }
    
    // Maximum number of joints influences for all mesh parts.
    int max_influences_count() const {
        int max_influences_count = 0;
        for (size_t i = 0; i < parts.size(); ++i) {
            const int influences_count = parts[i].influences_count();
            max_influences_count = influences_count > max_influences_count
            ? influences_count
            : max_influences_count;
        }
        return max_influences_count;
    }
    
    // Test if the mesh has skinning informations.
    bool skinned() const {
        for (size_t i = 0; i < parts.size(); ++i) {
            if (parts[i].influences_count() != 0) {
                return true;
            }
        }
        return false;
    }
    
    // Returns the number of joints used to skin the mesh.
    int num_joints() const { return static_cast<int>(inverse_bind_poses.size()); }
    
    // Returns the highest joint number used in the skeleton.
    int highest_joint_index() const {
        // Takes advantage that joint_remaps is sorted.
        return joint_remaps.size() != 0 ? static_cast<int>(joint_remaps.back()) : 0;
    }
    
    // Defines a portion of the mesh. A mesh is subdivided in sets of vertices
    // with the same number of joint influences.
    struct Part {
        int vertex_count() const { return static_cast<int>(positions.size()) / 3; }
        
        int influences_count() const {
            const int _vertex_count = vertex_count();
            if (_vertex_count == 0) {
                return 0;
            }
            return static_cast<int>(joint_indices.size()) / _vertex_count;
        }
        
        typedef vox::vector<float> Positions;
        Positions positions;
        enum { kPositionsCpnts = 3 };  // x, y, z components
        
        typedef vox::vector<float> Normals;
        Normals normals;
        enum { kNormalsCpnts = 3 };  // x, y, z components
        
        typedef vox::vector<float> Tangents;
        Tangents tangents;
        enum { kTangentsCpnts = 4 };  // x, y, z, right or left handed.
        
        typedef vox::vector<float> UVs;
        UVs uvs;  // u, v components
        enum { kUVsCpnts = 2 };
        
        typedef vox::vector<uint8_t> Colors;
        Colors colors;
        enum { kColorsCpnts = 4 };  // r, g, b, a components
        
        typedef vox::vector<uint16_t> JointIndices;
        JointIndices joint_indices;  // Stride equals influences_count
        
        typedef vox::vector<float> JointWeights;
        JointWeights joint_weights;  // Stride equals influences_count - 1
    };
    typedef vox::vector<Part> Parts;
    Parts parts;
    
    // Triangles indices. Indices are shared across all parts.
    typedef vox::vector<uint16_t> TriangleIndices;
    TriangleIndices triangle_indices;
    
    // Joints remapping indices. As a skin might be influenced by a part of the
    // skeleton only, joint indices and inverse bind pose matrices are reordered
    // to contain only used ones. Note that this array is sorted.
    typedef vox::vector<uint16_t> JointRemaps;
    JointRemaps joint_remaps;
    
    // Inverse bind-pose matrices. These are only available for skinned meshes.
    typedef vox::vector<math::Float4x4> InversBindPoses;
    InversBindPoses inverse_bind_poses;
};
}  // namespace loader
} // offline

namespace io {
VOX_IO_TYPE_TAG("ozz-sample-Mesh-Part", offline::loader::Mesh::Part)
VOX_IO_TYPE_VERSION(1, offline::loader::Mesh::Part)

template <>
struct Extern<offline::loader::Mesh::Part> {
    static void Save(OArchive& _archive, const offline::loader::Mesh::Part* _parts,
                     size_t _count);
    static void Load(IArchive& _archive, offline::loader::Mesh::Part* _parts,
                     size_t _count, uint32_t _version);
};

VOX_IO_TYPE_TAG("ozz-sample-Mesh", offline::loader::Mesh)
VOX_IO_TYPE_VERSION(1, offline::loader::Mesh)

template <>
struct Extern<offline::loader::Mesh> {
    static void Save(OArchive& _archive, const offline::loader::Mesh* _meshes,
                     size_t _count);
    static void Load(IArchive& _archive, offline::loader::Mesh* _meshes, size_t _count,
                     uint32_t _version);
};
}  // namespace io
} // vox

#endif /* fbx_mesh_hpp */
