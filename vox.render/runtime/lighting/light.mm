//
//  light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "light.h"
#include "../scene.h"

namespace vox {
Light::Light(Entity* entity):
Component(entity) {
}

math::Matrix Light::viewMatrix() {
    return math::invert(entity()->transform->worldMatrix());
}

math::Matrix Light::inverseViewMatrix() {
    return entity()->transform->worldMatrix();
}

void Light::updateShadowMatrix() {
    auto viewMatrix = invert(entity()->transform->worldMatrix());
    auto projMatrix = shadowProjectionMatrix();
    auto vp = projMatrix * viewMatrix;
    shadow.vp.columns[0] = simd_make_float4(vp.elements[0], vp.elements[1], vp.elements[2], vp.elements[3]);
    shadow.vp.columns[1] = simd_make_float4(vp.elements[4], vp.elements[5], vp.elements[6], vp.elements[7]);
    shadow.vp.columns[2] = simd_make_float4(vp.elements[8], vp.elements[9], vp.elements[10], vp.elements[11]);
    shadow.vp.columns[3] = simd_make_float4(vp.elements[12], vp.elements[13], vp.elements[14], vp.elements[15]);
}

void Light::_onEnable() {
    scene()->light_manager.attachRenderLight(this);
}

void Light::_onDisable() {
    scene()->light_manager.detachRenderLight(this);
}

}
