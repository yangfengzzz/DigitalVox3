//
//  mesh_renderer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef mesh_renderer_hpp
#define mesh_renderer_hpp

#include "../renderer.h"

namespace vox {
class Mesh;
using MeshPtr = std::shared_ptr<Mesh>;

class MeshRenderer: Renderer {
public:
    void setMesh(const MeshPtr& mesh);
    MeshPtr mesh();
    
private:
    void _render(Camera* camera) override;
    
    void _onDestroy() override;

    void _updateBounds(const BoundingBox& worldBounds) override;
    
private:
    MeshPtr _mesh;
    std::unique_ptr<UpdateFlag> _meshUpdateFlag;
    
};

}

#endif /* mesh_renderer_hpp */
