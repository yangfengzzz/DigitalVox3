//
//  shadow_manager.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#ifndef shadow_manager_hpp
#define shadow_manager_hpp

#include "shadow_pass.h"
#include "shadow_map_material.h"

namespace vox {
/**
 * Shadow plug-in.
 */
class ShadowManager {
public:
    void preRender(Scene* scene, Camera* camera);
    
    /**
     * Add RenderPass for rendering shadows.
     * @param camera - The camera for rendering
     */
    void addShadowPass(Camera* camera);
    
    /**
     * Add RenderPass for rendering shadow map.
     * @param camera - The camera for rendering
     * @param light - The light that the shadow belongs to
     */
    ShadowMapPass* addShadowMapPass(Camera* camera, Light* light);
    
    /**
     * Update the renderPassFlag state of renderers in the scene.
     * @param renderQueue - Render queue
     */
    void updatePassRenderFlag(RenderQueue& renderQueue);
    
private:
    ShadowPass* _shadowPass;
    std::shared_ptr<ShadowMapMaterial> _shadowMapMaterial;
};

}

#endif /* shadow_manager_hpp */
