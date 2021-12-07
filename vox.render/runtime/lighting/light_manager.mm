//
//  light_manager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "light_manager.h"
#include "point_light.h"
#include "spot_light.h"
#include "direct_light.h"
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
    /**
     * ambientLight and envMapLight only use the last one in the scene
     * */
    size_t directLightCount = 0;
    size_t pointLightCount = 0;
    size_t spotLightCount = 0;
    
    for (size_t i = 0; i < visibleLights.size(); i++) {
        const auto& light = visibleLights[i];
        if (dynamic_cast<DirectLight*>(light) != nullptr) {
            light->_appendData(directLightCount++);
        } else if (dynamic_cast<PointLight*>(light) != nullptr) {
            light->_appendData(pointLightCount++);
        } else if (dynamic_cast<SpotLight*>(light) != nullptr) {
            light->_appendData(spotLightCount++);
        }
    }
    
    if (directLightCount) {
        DirectLight::_updateShaderData(shaderData);
        shaderData.enableMacro(DIRECT_LIGHT_COUNT, std::make_pair(directLightCount, MTLDataTypeInt));
    } else {
        shaderData.disableMacro(DIRECT_LIGHT_COUNT);
    }
    
    if (pointLightCount) {
        PointLight::_updateShaderData(shaderData);
        shaderData.enableMacro(POINT_LIGHT_COUNT, std::make_pair(pointLightCount, MTLDataTypeInt));
    } else {
        shaderData.disableMacro(POINT_LIGHT_COUNT);
    }
    
    if (spotLightCount) {
        SpotLight::_updateShaderData(shaderData);
        shaderData.enableMacro(SPOT_LIGHT_COUNT, std::make_pair(spotLightCount, MTLDataTypeInt));
    } else {
        shaderData.disableMacro(SPOT_LIGHT_COUNT);
    }
}

}