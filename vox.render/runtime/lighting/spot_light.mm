//
//  spot_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "spot_light.h"
#include "../shader/shader.h"
#include "../entity.h"
#include "../rhi-metal/render_pipeline_state.h"

namespace vox {
ShaderProperty SpotLight::_colorProperty = Shader::createProperty("u_spotLightColor", ShaderDataGroup::Scene);
ShaderProperty SpotLight::_positionProperty = Shader::createProperty("u_spotLightPosition", ShaderDataGroup::Scene);
ShaderProperty SpotLight::_directionProperty = Shader::createProperty("u_spotLightDirection", ShaderDataGroup::Scene);
ShaderProperty SpotLight::_distanceProperty = Shader::createProperty("u_spotLightDistance", ShaderDataGroup::Scene);
ShaderProperty SpotLight::_angleCosProperty = Shader::createProperty("u_spotLightAngleCos", ShaderDataGroup::Scene);
ShaderProperty SpotLight::_penumbraCosProperty = Shader::createProperty("u_spotLightPenumbraCos", ShaderDataGroup::Scene);

std::array<math::Color, Light::_maxLight> SpotLight::_combinedColor = {};
std::array<math::Float3, Light::_maxLight> SpotLight::_combinedPosition = {};
std::array<math::Float3, Light::_maxLight> SpotLight::_combinedDirection = {};
std::array<float, Light::_maxLight> SpotLight::_combinedDistance = {};
std::array<float, Light::_maxLight> SpotLight::_combinedAngleCos = {};
std::array<float, Light::_maxLight> SpotLight::_combinedPenumbraCos = {};

SpotLight::SpotLight(Entity* entity):
Light(entity) {
    RenderPipelineState::register_fragment_uploader<std::array<math::Color, Light::_maxLight>>(
    [](const std::array<math::Color, Light::_maxLight>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<math::Color, Light::_maxLight>) atIndex:location];
    });
    
    RenderPipelineState::register_fragment_uploader<std::array<math::Float3, Light::_maxLight>>(
    [](const std::array<math::Float3, Light::_maxLight>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<math::Float3, Light::_maxLight>) atIndex:location];
    });
    
    RenderPipelineState::register_fragment_uploader<std::array<float, Light::_maxLight>>(
    [](const std::array<float, Light::_maxLight>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<float, Light::_maxLight>) atIndex:location];
    });
}

void SpotLight::_appendData(size_t lightIndex) {
    _combinedColor[lightIndex] = color * intensity;
    _combinedPosition[lightIndex] = entity()->transform->worldPosition();
    _combinedDirection[lightIndex] = entity()->transform->worldForward();
    _combinedDistance[lightIndex] = distance;
    _combinedAngleCos[lightIndex] = std::cos(angle);
    _combinedPenumbraCos[lightIndex] = std::cos(angle + penumbra);
}

void SpotLight::_updateShaderData(ShaderData& shaderData) {
    shaderData.setData(SpotLight::_colorProperty, _combinedColor);
    shaderData.setData(SpotLight::_positionProperty, _combinedPosition);
    shaderData.setData(SpotLight::_directionProperty, _combinedDirection);
    shaderData.setData(SpotLight::_distanceProperty, _combinedDistance);
    shaderData.setData(SpotLight::_angleCosProperty, _combinedAngleCos);
    shaderData.setData(SpotLight::_penumbraCosProperty, _combinedPenumbraCos);
}

math::Matrix SpotLight::shadowProjectionMatrix() {
    const auto fov = std::min(M_PI / 2, angle * 2 * std::sqrt(2));
    return math::Matrix::perspective(fov, 1, 0.1, distance + 5);
}

}
