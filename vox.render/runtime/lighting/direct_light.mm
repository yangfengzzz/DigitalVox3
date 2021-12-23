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

std::array<math::Color, Light::MAX_LIGHT> DirectLight::_combinedColor = {};
std::array<math::Float3, Light::MAX_LIGHT> DirectLight::_combinedDirection = {};

DirectLight::DirectLight(Entity* entity):
Light(entity) {
    RenderPipelineState::register_fragment_uploader<std::array<math::Color, Light::MAX_LIGHT>>(
    [](const std::array<math::Color, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<math::Color, Light::MAX_LIGHT>) atIndex:location];
    });
    
    RenderPipelineState::register_fragment_uploader<std::array<math::Float3, Light::MAX_LIGHT>>(
    [](const std::array<math::Float3, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<math::Float3, Light::MAX_LIGHT>) atIndex:location];
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

math::Float3 DirectLight::direction() {
    return entity()->transform->worldForward();
}

math::Matrix DirectLight::shadowProjectionMatrix() {
    assert(false && "cascade shadow don't use this projection");
}

void DirectLight::_onEnable() {
    scene()->light_manager.attachDirectLight(this);
}

void DirectLight::_onDisable() {
    scene()->light_manager.detachDirectLight(this);
}

}
