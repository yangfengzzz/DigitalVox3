//
//  spot_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "spot_light.h"
#include "../entity.h"
#include "../scene.h"

namespace vox {
SpotLight::SpotLight(Entity *entity) :
Light(entity) {
}

void SpotLight::_onEnable() {
    scene()->light_manager.attachSpotLight(this);
}

void SpotLight::_onDisable() {
    scene()->light_manager.detachSpotLight(this);
}

void SpotLight::_updateShaderData(SpotLightData &shaderData) {
    shaderData.color = simd_make_float3(color.r * intensity, color.g * intensity, color.b * intensity);
    auto position = entity()->transform->worldPosition();
    shaderData.position = simd_make_float3(position.x, position.y, position.z);
    auto direction = entity()->transform->worldForward();
    shaderData.direction = simd_make_float3(direction.x, direction.y, direction.z);
    shaderData.distance = distance;
    shaderData.angleCos = std::cos(angle);
    shaderData.penumbraCos = std::cos(angle + penumbra);
}

// MARK: - Shadow
math::Matrix SpotLight::shadowProjectionMatrix() {
    const auto fov = std::min(M_PI / 2, angle * 2 * std::sqrt(2));
    return math::Matrix::perspective(fov, 1, 0.1, distance + 5);
}

void SpotLight::updateShadowMatrix() {
    auto viewMatrix = invert(entity()->transform->worldMatrix());
    auto projMatrix = shadowProjectionMatrix();
    auto vp = projMatrix * viewMatrix;
    shadow.vp[0] = vp.toSimdMatrix();
    shadow.cascadeSplits[0] = 1;
    shadow.cascadeSplits[1] = -1; // mark cascade with negative sign
}

}
