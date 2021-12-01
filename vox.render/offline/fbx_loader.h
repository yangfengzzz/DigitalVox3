//
//  fbx_loader.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#ifndef fbx_loader_hpp
#define fbx_loader_hpp

#include "fbx_mesh.h"

namespace vox {
namespace offline {
namespace loader {
bool loadScene(const char* mesh_filename, const char* skeleton_filename,
               std::vector<Mesh>& meshes);
} // loader
} // offline
} // vox

#endif /* fbx_loader_hpp */
