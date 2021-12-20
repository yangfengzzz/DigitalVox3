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
/**
 * MeshRenderer Component.
 */
class MeshRenderer: public Renderer {
public:
    explicit MeshRenderer(Entity* entity);
    
    /**
     * Mesh assigned to the renderer.
     */
    void setMesh(const MeshPtr& mesh);
    MeshPtr mesh();
    
private:
    void _render(Camera* camera) override;
    
    void _onDestroy() override;

    void _updateBounds(BoundingBox& worldBounds) override;
    
private:
    MeshPtr _mesh;
    std::unique_ptr<UpdateFlag> _meshUpdateFlag;
    
};

}

#endif /* mesh_renderer_hpp */
