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
#include "../rhi-metal/render_pipeline_state.h"
#include "../../log.h"

namespace vox {
LightManager::LightManager() {
    RenderPipelineState::register_vertex_uploader<std::array<ShadowData, MAX_SHADOW>>(
    [](const std::array<ShadowData, MAX_SHADOW>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(std::array<ShadowData, MAX_SHADOW>) atIndex:location];
    });
    
    RenderPipelineState::register_fragment_uploader<std::array<ShadowData, MAX_SHADOW>>(
    [](const std::array<ShadowData, MAX_SHADOW>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(std::array<ShadowData, MAX_SHADOW>) atIndex:location];
    });
}

//MARK: - Point Light
void LightManager::attachPointLight(PointLight* light) {
    auto iter = std::find(_pointLights.begin(), _pointLights.end(), light);
    if (iter == _pointLights.end()) {
        _pointLights.push_back(light);
    } else {
        log::Err() << "Light already attached." << std::endl;;
    }
}

void LightManager::detachPointLight(PointLight* light) {
    auto iter = std::find(_pointLights.begin(), _pointLights.end(), light);
    if (iter != _pointLights.end()) {
        _pointLights.erase(iter);
    }
}

const std::vector<PointLight*>& LightManager::pointLights() const {
    return _pointLights;
}

//MARK: - Spot Light
void LightManager::attachSpotLight(SpotLight* light) {
    auto iter = std::find(_spotLights.begin(), _spotLights.end(), light);
    if (iter == _spotLights.end()) {
        _spotLights.push_back(light);
    } else {
        log::Err() << "Light already attached." << std::endl;;
    }
}

void LightManager::detachSpotLight(SpotLight* light) {
    auto iter = std::find(_spotLights.begin(), _spotLights.end(), light);
    if (iter != _spotLights.end()) {
        _spotLights.erase(iter);
    }
}

const std::vector<SpotLight*>& LightManager::spotLights() const {
    return _spotLights;
}

//MARK: - Direct Light
void LightManager::attachDirectLight(DirectLight* light) {
    auto iter = std::find(_directLights.begin(), _directLights.end(), light);
    if (iter == _directLights.end()) {
        _directLights.push_back(light);
    } else {
        log::Err() << "Light already attached." << std::endl;;
    }
}

void LightManager::detachDirectLight(DirectLight* light) {
    auto iter = std::find(_directLights.begin(), _directLights.end(), light);
    if (iter != _directLights.end()) {
        _directLights.erase(iter);
    }
}

const std::vector<DirectLight*>& LightManager::directLights() const {
    return _directLights;
}

//MARK: - Internal Uploader
void LightManager::_updateShaderData(ShaderData& shaderData) {
    /**
     * ambientLight and envMapLight only use the last one in the scene
     * */
    size_t directLightCount = 0;
    size_t pointLightCount = 0;
    size_t spotLightCount = 0;
    
    for (size_t i = 0; i < _pointLights.size(); i++) {
        const auto& light = _pointLights[i];
        light->_appendData(pointLightCount++);
    }
    
    for (size_t i = 0; i < _spotLights.size(); i++) {
        const auto& light = _spotLights[i];
        light->_appendData(spotLightCount++);
    }
    
    for (size_t i = 0; i < _directLights.size(); i++) {
        const auto& light = _directLights[i];
        light->_appendData(directLightCount++);
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
