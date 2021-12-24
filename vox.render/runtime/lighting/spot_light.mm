//
//  spot_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "spot_light.h"
#include "../shader/shader.h"
#include "../entity.h"
#include "../scene.h"
#include "../rhi-metal/render_pipeline_state.h"

namespace vox {
ShaderProperty SpotLight::_spotLightProperty = Shader::createProperty("u_spotLight", ShaderDataGroup::Scene);
std::array<SpotLightData, Light::MAX_LIGHT> SpotLight::_shaderData = {};

SpotLight::SpotLight(Entity* entity):
Light(entity) {
    RenderPipelineState::register_fragment_uploader<std::array<SpotLightData, Light::MAX_LIGHT>>(
    [](const std::array<SpotLightData, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<SpotLightData, Light::MAX_LIGHT>) atIndex:location];
    });
}

void SpotLight::_appendData(size_t lightIndex) {
    _shaderData[lightIndex].color = simd_make_float3(color.r * intensity, color.g * intensity, color.b * intensity);
    auto position = entity()->transform->worldPosition();
    _shaderData[lightIndex].position = simd_make_float3(position.x, position.y, position.z);
    auto direction = entity()->transform->worldForward();
    _shaderData[lightIndex].direction = simd_make_float3(direction.x, direction.y, direction.z);
    _shaderData[lightIndex].distance = distance;
    _shaderData[lightIndex].angleCos = std::cos(angle);
    _shaderData[lightIndex].penumbraCos = std::cos(angle + penumbra);
}

void SpotLight::_updateShaderData(ShaderData& shaderData) {
    shaderData.setData(SpotLight::_spotLightProperty, _shaderData);
}

math::Matrix SpotLight::shadowProjectionMatrix() {
    const auto fov = std::min(M_PI / 2, angle * 2 * std::sqrt(2));
    return math::Matrix::perspective(fov, 1, 0.1, distance + 5);
}

void SpotLight::updateShadowMatrix() {
    auto viewMatrix = invert(entity()->transform->worldMatrix());
    auto projMatrix = shadowProjectionMatrix();
    auto vp = projMatrix * viewMatrix;
    shadow.vp[0] = vp.toSimdMatrix();
    shadow.cascadeSplits[0] = 1; shadow.cascadeSplits[1] = -1; // mark cascade with negative sign
}

void SpotLight::_onEnable() {
    scene()->light_manager.attachSpotLight(this);
}

void SpotLight::_onDisable() {
    scene()->light_manager.detachSpotLight(this);
}

}
