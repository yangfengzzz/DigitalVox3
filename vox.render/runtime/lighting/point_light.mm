//
//  point_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "point_light.h"
#include "../shader/shader.h"
#include "../entity.h"

namespace vox {
ShaderProperty PointLight::_colorProperty = Shader::createProperty("u_pointLightColor", ShaderDataGroup::Scene);
ShaderProperty PointLight::_positionProperty = Shader::createProperty("u_pointLightPosition", ShaderDataGroup::Scene);
ShaderProperty PointLight::_distanceProperty = Shader::createProperty("u_pointLightDistance", ShaderDataGroup::Scene);

PointLight::PointLight(Entity* entity):
Light(entity) {}

void PointLight::_appendData(size_t lightIndex) {
    _combinedColor[lightIndex] = color * intensity;
    _combinedPosition[lightIndex] = entity()->transform->worldPosition();
    _combinedDistance[lightIndex] = distance;
}

void PointLight::_updateShaderData(ShaderData& shaderData) {
    shaderData.setData(PointLight::_colorProperty, _combinedColor);
    shaderData.setData(PointLight::_positionProperty, _combinedPosition);
    shaderData.setData(PointLight::_distanceProperty, _combinedDistance);
}

}
