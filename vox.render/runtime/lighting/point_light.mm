//
//  point_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "point_light.h"
#include "../shader/shader.h"
#include "../entity.h"
#include "../scene.h"
#include "../rhi-metal/render_pipeline_state.h"

namespace vox {
ShaderProperty PointLight::_pointLightProperty = Shader::createProperty("u_pointLight", ShaderDataGroup::Scene);
std::array<PointLightData, Light::MAX_LIGHT> PointLight::_shaderData = {};

PointLight::PointLight(Entity* entity):
Light(entity) {
    RenderPipelineState::register_vertex_uploader<std::array<PointLightData, Light::MAX_LIGHT>>(
    [](const std::array<PointLightData, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: x.data() length:sizeof(std::array<PointLightData, Light::MAX_LIGHT>) atIndex:location];
    });
    
    RenderPipelineState::register_fragment_uploader<std::array<PointLightData, Light::MAX_LIGHT>>(
    [](const std::array<PointLightData, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<PointLightData, Light::MAX_LIGHT>) atIndex:location];
    });
}

void PointLight::_appendData(size_t lightIndex) {
    _shaderData[lightIndex].color = simd_make_float3(color.r * intensity, color.g * intensity, color.b * intensity);
    auto position = entity()->transform->worldPosition();
    _shaderData[lightIndex].position = simd_make_float3(position.x, position.y, position.z);
    _shaderData[lightIndex].distance = distance;
}

void PointLight::_updateShaderData(ShaderData& shaderData) {
    shaderData.setData(PointLight::_pointLightProperty, _shaderData);
}

math::Matrix PointLight::shadowProjectionMatrix() {
    return math::Matrix::perspective(math::degreeToRadian(50), 1, 0.5, 50);
}

void PointLight::updateShadowMatrix() {
    auto projMatrix = shadowProjectionMatrix();
    auto worldPos = entity()->transform->worldPosition();
    shadow.lightPos = simd_make_float3(worldPos.x, worldPos.y, worldPos.z);
    
    for (int i = 0; i < 6; i++) {
        entity()->transform->lookAt(worldPos + cubeMapDirection[i].first, cubeMapDirection[i].second);
        auto viewMatrix = invert(entity()->transform->worldMatrix());
        auto vp = projMatrix * viewMatrix;
        shadow.vp[i] = vp.toSimdMatrix();
    }
}

void PointLight::_onEnable() {
    scene()->light_manager.attachPointLight(this);
}

void PointLight::_onDisable() {
    scene()->light_manager.detachPointLight(this);
}


}
