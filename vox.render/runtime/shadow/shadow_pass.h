//
//  shadow_pass.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#ifndef shadow_pass_hpp
#define shadow_pass_hpp

#include "../render_pipeline/render_pass.h"

namespace vox {
/**
 * RenderPass for rendering shadow.
 */
class ShadowPass :public RenderPass {
public:
    ShadowPass(const std::string& name, int priority,
               MTLRenderPassDescriptor* renderTarget,
               MaterialPtr replaceMaterial, Layer mask);
    
    void preRender(Camera* camera, const RenderQueue& opaqueQueue,
                   const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) override;
private:
    MaterialPtr replaceMaterial;
};

}


#endif /* shadow_pass_hpp */
