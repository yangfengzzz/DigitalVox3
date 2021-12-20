//
//  shadow_map_pass.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#ifndef shadow_map_pass_hpp
#define shadow_map_pass_hpp

#include "../render_pipeline/render_pass.h"
#include "../lighting/light.h"
#include "../shader/shader_property.h"

namespace vox {
/**
 * RenderPass for rendering shadow map.
 */
class ShadowMapPass :public RenderPass {
public:
    /**
     * Constructor.
     * @param light  - The light that the shadow belongs to
     */
    ShadowMapPass(const std::string& name, int priority,
                  MTLRenderPassDescriptor* renderTarget,
                  MaterialPtr replaceMaterial,
                  Layer mask,  Light* light);
    
    void preRender(Camera* camera, const RenderQueue& opaqueQueue,
                   const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) override;
private:
    static ShaderProperty _viewMatFromLightProperty;
    static ShaderProperty _projMatFromLightProperty;
    
    MaterialPtr _shadowMapMaterial;
    Light* light = nullptr;
};

}

#endif /* shadow_map_pass_hpp */
