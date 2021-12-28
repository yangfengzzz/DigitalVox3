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
#include "../shader/shader.h"
#include "../scene.h"
#include "../engine.h"
#include "../../log.h"

namespace vox {
ShaderProperty LightManager::_pointLightProperty = Shader::createProperty("u_pointLight", ShaderDataGroup::Scene);
ShaderProperty LightManager::_spotLightProperty = Shader::createProperty("u_spotLight", ShaderDataGroup::Scene);
ShaderProperty LightManager::_directLightProperty = Shader::createProperty("u_directLight", ShaderDataGroup::Scene);

LightManager::LightManager(Scene *scene) :
_scene(scene) {
    RenderPipelineState::register_vertex_uploader<std::array<ShadowData, MAX_SHADOW>>(
                                                                                      [](const std::array<ShadowData, MAX_SHADOW> &x, size_t location, id <MTLRenderCommandEncoder> encoder) {
                                                                                          [encoder setVertexBytes:&x length:sizeof(std::array<ShadowData, MAX_SHADOW>) atIndex:location];
                                                                                      });
    
    RenderPipelineState::register_fragment_uploader<std::array<ShadowData, MAX_SHADOW>>(
                                                                                        [](const std::array<ShadowData, MAX_SHADOW> &x, size_t location, id <MTLRenderCommandEncoder> encoder) {
                                                                                            [encoder setFragmentBytes:&x length:sizeof(std::array<ShadowData, MAX_SHADOW>) atIndex:location];
                                                                                        });
    
    RenderPipelineState::register_vertex_uploader<std::array<CubeShadowData, MAX_CUBE_SHADOW>>(
                                                                                               [](const std::array<CubeShadowData, MAX_CUBE_SHADOW> &x, size_t location, id <MTLRenderCommandEncoder> encoder) {
                                                                                                   [encoder setVertexBytes:&x length:sizeof(std::array<CubeShadowData, MAX_CUBE_SHADOW>) atIndex:location];
                                                                                               });
    
    RenderPipelineState::register_fragment_uploader<std::array<CubeShadowData, MAX_CUBE_SHADOW>>(
                                                                                                 [](const std::array<CubeShadowData, MAX_CUBE_SHADOW> &x, size_t location, id <MTLRenderCommandEncoder> encoder) {
                                                                                                     [encoder setFragmentBytes:&x length:sizeof(std::array<CubeShadowData, MAX_CUBE_SHADOW>) atIndex:location];
                                                                                                 });
}

//MARK: - Point Light
void LightManager::attachPointLight(PointLight *light) {
    auto iter = std::find(_pointLights.begin(), _pointLights.end(), light);
    if (iter == _pointLights.end()) {
        _pointLights.push_back(light);
    } else {
        log::Err() << "Light already attached." << std::endl;;
    }
}

void LightManager::detachPointLight(PointLight *light) {
    auto iter = std::find(_pointLights.begin(), _pointLights.end(), light);
    if (iter != _pointLights.end()) {
        _pointLights.erase(iter);
    }
}

const std::vector<PointLight *> &LightManager::pointLights() const {
    return _pointLights;
}

//MARK: - Spot Light
void LightManager::attachSpotLight(SpotLight *light) {
    auto iter = std::find(_spotLights.begin(), _spotLights.end(), light);
    if (iter == _spotLights.end()) {
        _spotLights.push_back(light);
    } else {
        log::Err() << "Light already attached." << std::endl;;
    }
}

void LightManager::detachSpotLight(SpotLight *light) {
    auto iter = std::find(_spotLights.begin(), _spotLights.end(), light);
    if (iter != _spotLights.end()) {
        _spotLights.erase(iter);
    }
}

const std::vector<SpotLight *> &LightManager::spotLights() const {
    return _spotLights;
}

//MARK: - Direct Light
void LightManager::attachDirectLight(DirectLight *light) {
    auto iter = std::find(_directLights.begin(), _directLights.end(), light);
    if (iter == _directLights.end()) {
        _directLights.push_back(light);
    } else {
        log::Err() << "Light already attached." << std::endl;;
    }
}

void LightManager::detachDirectLight(DirectLight *light) {
    auto iter = std::find(_directLights.begin(), _directLights.end(), light);
    if (iter != _directLights.end()) {
        _directLights.erase(iter);
    }
}

const std::vector<DirectLight *> &LightManager::directLights() const {
    return _directLights;
}

//MARK: - Internal Uploader
void LightManager::_updateShaderData(ShaderData &shaderData) {
    size_t pointLightCount = _pointLights.size();
    _pointLightDatas.resize(pointLightCount);
    size_t spotLightCount = _spotLights.size();
    _spotLightDatas.resize(spotLightCount);
    size_t directLightCount = _directLights.size();
    _directLightDatas.resize(directLightCount);
    
    for (size_t i = 0; i < pointLightCount; i++) {
        _pointLights[i]->_updateShaderData(_pointLightDatas[i]);
    }
    
    for (size_t i = 0; i < spotLightCount; i++) {
        _spotLights[i]->_updateShaderData(_spotLightDatas[i]);
    }
    
    for (size_t i = 0; i < directLightCount; i++) {
        _directLights[i]->_updateShaderData(_directLightDatas[i]);
    }
    
    if (directLightCount) {
        if (_directLightBuffer == nullptr || [_directLightBuffer length] != sizeof(DirectLightData) * _directLightDatas.size()) {
            _directLightBuffer = _scene->engine()->resourceLoader()->buildBuffer(_directLightDatas.data(),
                                                                                 _directLightDatas.size() * sizeof(DirectLightData), NULL);
        } else {
            memcpy([_directLightBuffer contents], _directLightDatas.data(), _directLightDatas.size() * sizeof(DirectLightData));
        }
        
        shaderData.enableMacro(DIRECT_LIGHT_COUNT, std::make_pair(directLightCount, MTLDataTypeInt));
        shaderData.setData(LightManager::_directLightProperty, _directLightBuffer);
    } else {
        shaderData.disableMacro(DIRECT_LIGHT_COUNT);
    }
    
    if (pointLightCount) {
        if (_pointLightBuffer == nullptr || [_pointLightBuffer length] != sizeof(PointLightData) * _pointLightDatas.size()) {
            _pointLightBuffer = _scene->engine()->resourceLoader()->buildBuffer(_pointLightDatas.data(),
                                                                                _pointLightDatas.size() * sizeof(PointLightData), NULL);
        } else {
            memcpy([_pointLightBuffer contents], _pointLightDatas.data(), _pointLightDatas.size() * sizeof(PointLightData));
        }
        
        shaderData.enableMacro(POINT_LIGHT_COUNT, std::make_pair(pointLightCount, MTLDataTypeInt));
        shaderData.setData(LightManager::_pointLightProperty, _pointLightBuffer);
    } else {
        shaderData.disableMacro(POINT_LIGHT_COUNT);
    }
    
    if (spotLightCount) {
        if (_spotLightBuffer == nullptr || [_spotLightBuffer length] != sizeof(SpotLightData) * _spotLightDatas.size()) {
            _spotLightBuffer = _scene->engine()->resourceLoader()->buildBuffer(_spotLightDatas.data(),
                                                                               _spotLightDatas.size() * sizeof(SpotLightData), NULL);
        } else {
            memcpy([_spotLightBuffer contents], _spotLightDatas.data(), _spotLightDatas.size() * sizeof(SpotLightData));
        }
        
        shaderData.enableMacro(SPOT_LIGHT_COUNT, std::make_pair(spotLightCount, MTLDataTypeInt));
        shaderData.setData(LightManager::_spotLightProperty, _spotLightBuffer);
    } else {
        shaderData.disableMacro(SPOT_LIGHT_COUNT);
    }
}

}
