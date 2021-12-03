//
//  collider.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#include "collider.h"
#include "../entity.h"
#include "shape/collider_shape.h"
#include "../engine.h"

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
        engine()->_physicsManager._addColliderShape(shape);
        _nativeActor->attachShape(*shape->_nativeShape);
        shape->_collider = this;
    }
}

void Collider::removeShape(const ColliderShapePtr& shape) {
    auto iter = std::find(_shapes.begin(), _shapes.end(), shape);
    
    if (iter != _shapes.end()) {
        _shapes.erase(iter);
        _nativeActor->detachShape(*shape->_nativeShape);
        engine()->_physicsManager._removeColliderShape(shape);
        shape->_collider = nullptr;
    }
}

void Collider::clearShapes() {
    for (size_t i = 0 ; i < _shapes.size(); i++) {
        _nativeActor->detachShape(*_shapes[i]->_nativeShape);
        engine()->_physicsManager._removeColliderShape(_shapes[i]);
    }
    _shapes.clear();
}

void Collider::_onUpdate() {
    if (_updateFlag->flag) {
        const auto& p = entity()->transform->worldPosition();
        const auto& q = entity()->transform->worldRotationQuaternion();
        _nativeActor->setGlobalPose(PxTransform(PxVec3(p.x, p.y, p.z), PxQuat(q.x, q.y, q.z, q.w)));
        _updateFlag->flag = false;

        // let worldScale = transform!.lossyWorldScale;
        for (auto& _shape : _shapes) {
        //    _shape->_nativeShape->setWorldScale(worldScale);
        }
    }
}

void Collider::_onEnable() {
    engine()->_physicsManager._addCollider(this);
}

void Collider::_onDisable() {
    engine()->_physicsManager._removeCollider(this);
}

void Collider::_onDestroy() {
    clearShapes();
}

}
}
