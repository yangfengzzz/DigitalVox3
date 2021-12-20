//
//  shadow_pass.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#include "shadow_pass.h"

namespace vox {
ShadowPass::ShadowPass(const std::string& name, int priority,
                       MTLRenderPassDescriptor* renderTarget, Layer mask):
RenderPass(name, priority, renderTarget, mask){
    clearFlags = CameraClearFlags::None;
}

void ShadowPass::preRender(Camera* camera, const RenderQueue& opaqueQueue,
                           const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) {
    
}

}
