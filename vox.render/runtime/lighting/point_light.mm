//
//  point_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "point_light.h"
#include "../entity.h"
#include "../scene.h"

namespace vox {
PointLight::PointLight(Entity* entity):
Light(entity) {
}

void PointLight::_onEnable() {
    scene()->light_manager.attachPointLight(this);
}

void PointLight::_onDisable() {
    scene()->light_manager.detachPointLight(this);
}

void PointLight::_updateShaderData(PointLightData& shaderData) {
    shaderData.color = simd_make_float3(color.r * intensity, color.g * intensity, color.b * intensity);
    auto position = entity()->transform->worldPosition();
    shaderData.position = simd_make_float3(position.x, position.y, position.z);
    shaderData.distance = distance;
}

//MARK: - Shadow
math::Matrix PointLight::shadowProjectionMatrix() {
    return math::Matrix::perspective(math::degreeToRadian(90), 1, 0.1, 100);
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

}
