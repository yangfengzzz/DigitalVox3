//
//  spot_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "spot_light.h"
#include "../shader/shader.h"
#include "../entity.h"

namespace vox {
ShaderProperty SpotLight::_colorProperty = Shader::createProperty("u_spotLightColor", ShaderDataGroup::Scene);
ShaderProperty SpotLight::_positionProperty = Shader::createProperty("u_spotLightPosition", ShaderDataGroup::Scene);
ShaderProperty SpotLight::_directionProperty = Shader::createProperty("u_spotLightDirection", ShaderDataGroup::Scene);
ShaderProperty SpotLight::_distanceProperty = Shader::createProperty("u_spotLightDistance", ShaderDataGroup::Scene);
ShaderProperty SpotLight::_angleCosProperty = Shader::createProperty("u_spotLightAngleCos", ShaderDataGroup::Scene);
ShaderProperty SpotLight::_penumbraCosProperty = Shader::createProperty("u_spotLightPenumbraCos", ShaderDataGroup::Scene);

SpotLight::SpotLight(Entity* entity):
Light(entity) {}

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

}
