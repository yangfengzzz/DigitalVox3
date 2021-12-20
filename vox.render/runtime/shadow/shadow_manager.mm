//
//  shadow_manager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#include "shadow_manager.h"
#include "shadow_map_pass.h"
#include "shadow_material.h"
#include "../scene.h"
#include "../lighting/light.h"
#include "../render_pipeline/render_queue.h"
#include "../renderer.h"
#include "../entity.h"
#include "../camera.h"

namespace vox {
void ShadowManager::preRender(Scene* scene, Camera* camera) {
    const auto& lights = scene->light_manager.visibleLights;
    
    if (lights.size() > 0) {
        // Check RenderPass for rendering shadows.
        if (!_shadowPass) {
            addShadowPass(camera);
        }
        
        // Check RenderPass for rendering shadow map.
        auto& renderPipeline = camera->_renderPipeline;
        
        for (size_t i = 0, len = lights.size(); i < len; i++) {
            const auto& lgt = lights[i];
            if (lgt->enableShadow() && !lgt->shadowMapPass) {
                lgt->shadowMapPass = addShadowMapPass(camera, lgt);
            } else if (!lgt->enableShadow() && lgt->shadowMapPass) {
                renderPipeline.removeRenderPass(lgt->shadowMapPass);
                lgt->shadowMapPass = nullptr;
            }
        }
        
        updatePassRenderFlag(renderPipeline._opaqueQueue);
        updatePassRenderFlag(renderPipeline._alphaTestQueue);
        updatePassRenderFlag(renderPipeline._transparentQueue);
    }
}

void ShadowManager::addShadowPass(Camera* camera) {
    const auto shadowMaterial = std::make_shared<ShadowMaterial>(camera->engine());
    auto shadowPass = std::make_unique<ShadowPass>("ShadowPass", 1, nullptr, shadowMaterial, Layer::Layer30); // SHADOW
    _shadowPass = shadowPass.get();
    auto& renderer = camera->_renderPipeline;
    renderer.addRenderPass(std::move(shadowPass));
}

ShadowMapPass* ShadowManager::addShadowMapPass(Camera* camera, Light* light) {
    // Share shadow map material.
    if (!_shadowMapMaterial) {
        _shadowMapMaterial = std::make_shared<ShadowMapMaterial>(camera->engine());
    }
    
    auto shadowMapPass = std::make_unique<ShadowMapPass>("ShadowMapPass",
                                                         -1,
                                                         light->shadowRenderTarget(),
                                                         _shadowMapMaterial,
                                                         Layer::Layer31, // SHADOW_MAP
                                                         light);
    auto passPtr = shadowMapPass.get();
    camera->addRenderPass(std::move(shadowMapPass));
    return passPtr;
}

void ShadowManager::updatePassRenderFlag(RenderQueue& renderQueue) {
    auto& items = renderQueue.items;
    for (size_t i = 0, len = items.size(); i < len; i++) {
        auto& item = items[i];
        auto ability = item.component;
        
        const auto receiveShadow = ability->receiveShadow;
        const auto castShadow = ability->castShadow;
        if (receiveShadow == true) {
            ability->entity()->layer |= Layer::Layer30; //SHADOW;
        } else if (receiveShadow == false) {
            ability->entity()->layer &= ~Layer::Layer30; //SHADOW;
        }
        
        if (castShadow == true) {
            ability->entity()->layer |= Layer::Layer31; //SHADOW_MAP;
        } else if (castShadow == false) {
            ability->entity()->layer &= ~Layer::Layer31; //SHADOW_MAP;
        }
    }
}

}
