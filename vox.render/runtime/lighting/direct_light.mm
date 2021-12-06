//
//  direct_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "direct_light.h"
#include "../shader/shader.h"
#include "../entity.h"

namespace vox {
ShaderProperty DirectLight::_colorProperty = Shader::createProperty("u_directLightColor", ShaderDataGroup::Scene);
ShaderProperty DirectLight::_directionProperty = Shader::createProperty("u_directLightDirection", ShaderDataGroup::Scene);

std::array<math::Color, Light::_maxLight> DirectLight::_combinedColor = {};
std::array<math::Float3, Light::_maxLight> DirectLight::_combinedDirection = {};

DirectLight::DirectLight(Entity* entity):
Light(entity) {}

void DirectLight::_appendData(size_t lightIndex) {
    _combinedColor[lightIndex] = color * intensity;
    _combinedDirection[lightIndex] = entity()->transform->worldForward();
}

void DirectLight::_updateShaderData(ShaderData& shaderData) {
    shaderData.setData(DirectLight::_colorProperty, _combinedColor);
    shaderData.setData(DirectLight::_directionProperty, _combinedDirection);
}

}
