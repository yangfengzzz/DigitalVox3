//
//  direct_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "direct_light.h"
#include "../scene.h"
#include "../entity.h"

namespace vox {
DirectLight::DirectLight(Entity* entity):
Light(entity) {
}

void DirectLight::_onEnable() {
    scene()->light_manager.attachDirectLight(this);
}

void DirectLight::_onDisable() {
    scene()->light_manager.detachDirectLight(this);
}

void DirectLight::_updateShaderData(DirectLightData& shaderData) {
    shaderData.color = simd_make_float3(color.r * intensity, color.g * intensity, color.b * intensity);
    auto direction = entity()->transform->worldForward();
    shaderData.direction = simd_make_float3(direction.x, direction.y, direction.z);
}

//MARK: - Shadow
math::Float3 DirectLight::direction() {
    return entity()->transform->worldForward();
}

math::Matrix DirectLight::shadowProjectionMatrix() {
    assert(false && "cascade shadow don't use this projection");
}

}
