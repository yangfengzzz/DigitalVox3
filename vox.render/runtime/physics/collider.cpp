//
//  collider.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#include "collider.h"
#include "../entity.h"

namespace vox {
namespace physics {
Collider::Collider(Entity* entity):
Component(entity) {
    _updateFlag = entity->transform->registerWorldChangeFlag();
}

void Collider::addShape(const ColliderShape& shape) {
    
}

void Collider::removeShape(const ColliderShape& shape) {
    
}

void Collider::clearShapes() {
    
}

void Collider::_onUpdate() {
    
}

void Collider::_onEnable() {
    
}

void Collider::_onDisable() {
    
}

void Collider::_onDestroy() {
    
}

}
}
