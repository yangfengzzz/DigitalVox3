//
//  collider.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#include "collider.h"
#include "../entity.h"
#include "shape/collider_shape.h"

namespace vox {
namespace physics {
Collider::Collider(Entity* entity):
Component(entity) {
    _updateFlag = entity->transform->registerWorldChangeFlag();
}

void Collider::addShape(const ColliderShapePtr& shape) {
    const auto& oldCollider = shape->_collider;
    if (oldCollider != this) {
        if (oldCollider != nullptr) {
            oldCollider->removeShape(shape);
        }
        _shapes.push_back(shape);
        // engine.physicsManager!._addColliderShape(shape);
        _nativeActor->attachShape(*shape->_nativeShape);
        shape->_collider = this;
    }
}

void Collider::removeShape(const ColliderShapePtr& shape) {
    
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
