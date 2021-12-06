//
//  light_manager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "light_manager.h"
#include "../../log.h"

namespace vox {
void LightManager::attachRenderLight(Light* light) {
    auto iter = std::find(visibleLights.begin(), visibleLights.end(), light);
    if (iter == visibleLights.end()) {
        visibleLights.push_back(light);
    } else {
        log::Err() << "Light already attached." << std::endl;;
    }
}

void LightManager::detachRenderLight(Light* light) {
    auto iter = std::find(visibleLights.begin(), visibleLights.end(), light);
    if (iter != visibleLights.end()) {
        visibleLights.erase(iter);
    }
}

void LightManager::_updateShaderData(ShaderData& shaderData) {
    
}

}
