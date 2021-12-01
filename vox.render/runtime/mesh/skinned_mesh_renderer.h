//
//  skinned_mesh_renderer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#ifndef skinned_mesh_renderer_hpp
#define skinned_mesh_renderer_hpp

#include "mesh_renderer.h"

namespace vox {
class SkinnedMeshRenderer : public MeshRenderer {
public:
    void update(float deltaTime) override;

private:
};

}

#endif /* skinned_mesh_renderer_hpp */
