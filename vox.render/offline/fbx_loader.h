//
//  fbx_loader.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#ifndef fbx_loader_hpp
#define fbx_loader_hpp

#include "fbx_mesh.h"
#include "../runtime/animation/skeleton.h"

namespace vox {
namespace offline {
namespace loader {
bool loadScene(const char* _filename, const animation::Skeleton& skeleton,
               vox::vector<Mesh>& _meshes);

// Loads a sample::Mesh from an ozz archive file named _filename.
// This function will fail and return false if the file cannot be opened or if
// it is not a valid ozz mesh archive. A valid mesh archive can be
// serialization API.
// _filename and _mesh must be non-nullptr.
bool loadMesh(const char* _filename, Mesh* _mesh);

// Loads n sample::Mesh from an ozz archive file named _filename.
// This function will fail and return false if the file cannot be opened or if
// it is not a valid ozz mesh archive. A valid mesh archive can be
// produced with ozz tools (fbx2skin) or using ozz animation serialization API.
// _filename and _mesh must be non-nullptr.
bool loadMeshes(const char* _filename, vox::vector<Mesh>* _meshes);

} // loader
} // offline
} // vox

#endif /* fbx_loader_hpp */
