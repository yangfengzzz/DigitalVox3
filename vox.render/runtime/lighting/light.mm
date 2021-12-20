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

void Light::_onEnable() {
    scene()->light_manager.attachRenderLight(this);
}

void Light::_onDisable() {
    scene()->light_manager.detachRenderLight(this);
}

}
