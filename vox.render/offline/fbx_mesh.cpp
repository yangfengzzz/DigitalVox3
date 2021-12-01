//
//  fbx_mesh.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#include "fbx_mesh.h"
#include "../containers/vector_archive.h"
#include "../memory/allocator.h"

#include "../io/archive.h"

#include "../maths/math_archive.h"
#include "../maths/simd_math_archive.h"

namespace vox {
namespace io {

void Extern<offline::loader::Mesh::Part>::Save(OArchive& _archive,
                                               const offline::loader::Mesh::Part* _parts,
                                               size_t _count) {
    for (size_t i = 0; i < _count; ++i) {
        const offline::loader::Mesh::Part& part = _parts[i];
        _archive << part.positions;
        _archive << part.normals;
        _archive << part.tangents;
        _archive << part.uvs;
        _archive << part.colors;
        _archive << part.joint_indices;
        _archive << part.joint_weights;
    }
}

void Extern<offline::loader::Mesh::Part>::Load(IArchive& _archive,
                                               offline::loader::Mesh::Part* _parts, size_t _count,
                                               uint32_t _version) {
    (void)_version;
    for (size_t i = 0; i < _count; ++i) {
        offline::loader::Mesh::Part& part = _parts[i];
        _archive >> part.positions;
        _archive >> part.normals;
        _archive >> part.tangents;
        _archive >> part.uvs;
        _archive >> part.colors;
        _archive >> part.joint_indices;
        _archive >> part.joint_weights;
    }
}

void Extern<offline::loader::Mesh>::Save(OArchive& _archive, const offline::loader::Mesh* _meshes,
                                         size_t _count) {
    for (size_t i = 0; i < _count; ++i) {
        const offline::loader::Mesh& mesh = _meshes[i];
        _archive << mesh.parts;
        _archive << mesh.triangle_indices;
        _archive << mesh.joint_remaps;
        _archive << mesh.inverse_bind_poses;
    }
}

void Extern<offline::loader::Mesh>::Load(IArchive& _archive, offline::loader::Mesh* _meshes,
                                         size_t _count, uint32_t _version) {
    (void)_version;
    for (size_t i = 0; i < _count; ++i) {
        offline::loader::Mesh& mesh = _meshes[i];
        _archive >> mesh.parts;
        _archive >> mesh.triangle_indices;
        _archive >> mesh.joint_remaps;
        _archive >> mesh.inverse_bind_poses;
    }
}
}  // namespace io
} // vox
