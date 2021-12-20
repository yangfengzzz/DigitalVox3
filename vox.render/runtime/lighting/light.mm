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
Component(entity),
shadow(LightShadow(this, entity->engine(), 512, 512)){
}

void Light::appendShadow(int lightIndex) {
    shadow.appendData(lightIndex);
}

math::Matrix Light::shadowProjectionMatrix() {
    return shadow.projectionMatrix;
}

MTLRenderPassDescriptor* Light::shadowRenderTarget() {
    return shadow.renderTarget();
}

math::Matrix Light::viewMatrix() {
    return math::invert(entity()->transform->worldMatrix());
}

math::Matrix Light::inverseViewMatrix() {
    return entity()->transform->worldMatrix();
}

void Light::_onEnable() {
    scene()->light_manager.attachRenderLight(this);
}

void Light::_onDisable() {
    scene()->light_manager.detachRenderLight(this);
}

}
