//
//  point_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "point_light.h"
#include "../shader/shader.h"
#include "../entity.h"
#include "../rhi-metal/render_pipeline_state.h"

namespace vox {
ShaderProperty PointLight::_colorProperty = Shader::createProperty("u_pointLightColor", ShaderDataGroup::Scene);
ShaderProperty PointLight::_positionProperty = Shader::createProperty("u_pointLightPosition", ShaderDataGroup::Scene);
ShaderProperty PointLight::_distanceProperty = Shader::createProperty("u_pointLightDistance", ShaderDataGroup::Scene);

std::array<math::Color, Light::MAX_LIGHT> PointLight::_combinedColor = {};
std::array<math::Float3, Light::MAX_LIGHT> PointLight::_combinedPosition = {};
std::array<float, Light::MAX_LIGHT> PointLight::_combinedDistance = {};

PointLight::PointLight(Entity* entity):
Light(entity) {
    RenderPipelineState::register_vertex_uploader<std::array<math::Color, Light::MAX_LIGHT>>(
    [](const std::array<math::Color, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: x.data() length:sizeof(std::array<math::Color, Light::MAX_LIGHT>) atIndex:location];
    });
    
    RenderPipelineState::register_vertex_uploader<std::array<math::Float3, Light::MAX_LIGHT>>(
    [](const std::array<math::Float3, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: x.data() length:sizeof(std::array<math::Float3, Light::MAX_LIGHT>) atIndex:location];
    });
    
    RenderPipelineState::register_vertex_uploader<std::array<float, Light::MAX_LIGHT>>(
    [](const std::array<float, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: x.data() length:sizeof(std::array<float, Light::MAX_LIGHT>) atIndex:location];
    });
    
    RenderPipelineState::register_fragment_uploader<std::array<math::Color, Light::MAX_LIGHT>>(
    [](const std::array<math::Color, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<math::Color, Light::MAX_LIGHT>) atIndex:location];
    });
    
    RenderPipelineState::register_fragment_uploader<std::array<math::Float3, Light::MAX_LIGHT>>(
    [](const std::array<math::Float3, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<math::Float3, Light::MAX_LIGHT>) atIndex:location];
    });
    
    RenderPipelineState::register_fragment_uploader<std::array<float, Light::MAX_LIGHT>>(
    [](const std::array<float, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<float, Light::MAX_LIGHT>) atIndex:location];
    });
}

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

math::Matrix PointLight::shadowProjectionMatrix() {
    return math::Matrix::perspective(math::degreeToRadian(50), 1, 0.5, 50);
}

}
