//
//  direct_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "direct_light.h"
#include "../scene.h"
#include "../shader/shader.h"
#include "../entity.h"
#include "../rhi-metal/render_pipeline_state.h"

namespace vox {
ShaderProperty DirectLight::_colorProperty = Shader::createProperty("u_directLightColor", ShaderDataGroup::Scene);
ShaderProperty DirectLight::_directionProperty = Shader::createProperty("u_directLightDirection", ShaderDataGroup::Scene);

std::array<math::Color, Light::_maxLight> DirectLight::_combinedColor = {};
std::array<math::Float3, Light::_maxLight> DirectLight::_combinedDirection = {};

DirectLight::DirectLight(Entity* entity):
Light(entity) {
    RenderPipelineState::register_fragment_uploader<std::array<math::Color, Light::_maxLight>>(
    [](const std::array<math::Color, Light::_maxLight>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<math::Color, Light::_maxLight>) atIndex:location];
    });
    
    RenderPipelineState::register_fragment_uploader<std::array<math::Float3, Light::_maxLight>>(
    [](const std::array<math::Float3, Light::_maxLight>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<math::Float3, Light::_maxLight>) atIndex:location];
    });
}

void DirectLight::_appendData(size_t lightIndex) {
    _combinedColor[lightIndex] = color * intensity;
    _combinedDirection[lightIndex] = entity()->transform->worldForward();
}

void DirectLight::_updateShaderData(ShaderData& shaderData) {
    shaderData.setData(DirectLight::_colorProperty, _combinedColor);
    shaderData.setData(DirectLight::_directionProperty, _combinedDirection);
}

math::Matrix DirectLight::shadowProjectionMatrix() {
    return math::Matrix::ortho(-17, 17, -10, 10, 0.1, 100);
}

void DirectLight::_onEnable() {
    scene()->light_manager.attachDirectLight(this);
}

void DirectLight::_onDisable() {
    scene()->light_manager.detachDirectLight(this);
}

}
