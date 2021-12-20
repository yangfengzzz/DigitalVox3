//
//  shadow_pass.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#include "shadow_pass.h"
#include "../camera.h"
#include "../scene.h"
#include "../lighting/light.h"
#include "light_shadow.h"

namespace vox {
ShadowPass::ShadowPass(const std::string& name, int priority,
                       MTLRenderPassDescriptor* renderTarget,
                       MaterialPtr replaceMaterial, Layer mask):
RenderPass(name, priority, renderTarget, mask),
replaceMaterial(replaceMaterial) {
    clearFlags = CameraClearFlags::None;
}

void ShadowPass::preRender(Camera* camera, const RenderQueue& opaqueQueue,
                           const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) {
    enabled = false;
    const auto& lightMgr = camera->scene()->light_manager;
    const auto& lights = lightMgr.visibleLights;
    auto& shaderData = replaceMaterial->shaderData;
    
    int shadowMapCount = 0;
    LightShadow::clearMap();
    for (size_t i = 0, len = lights.size(); i < len; i++) {
        const auto& lgt = lights[i];
        if (lgt->enableShadow()) {
            lgt->appendShadow(shadowMapCount++);
        }
    }
    
    if (shadowMapCount) {
        enabled = true;
        LightShadow::_updateShaderData(shaderData);
        shaderData.enableMacro(SHADOW_MAP_COUNT, std::make_pair(shadowMapCount, MTLDataTypeInt));
    } else {
        shaderData.disableMacro(SHADOW_MAP_COUNT);
    }
}

}
