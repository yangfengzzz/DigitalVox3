//
//  capsule_collider_shape.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "capsule_collider_shape.h"
#include "../physics_manager.h"

namespace vox {
namespace physics {
CapsuleColliderShape::CapsuleColliderShape() {
    _nativeGeometry = std::make_shared<PxCapsuleGeometry>(_radius * std::max(_pose.scale.x, _pose.scale.z), _height * _pose.scale.y);
    _nativeShape = PhysicsManager::_nativePhysics()->createShape(*_nativeGeometry, *_nativeMaterial, true);
    _nativeShape->setQueryFilterData(PxFilterData(PhysicsManager::_idGenerator++, 0, 0, 0));
    setLocalPose(_pose);
}

float CapsuleColliderShape::radius() {
    return _radius;
}

void CapsuleColliderShape::setRadius(float value) {
    _radius = value;
    switch (_upAxis) {
        case ColliderShapeUpAxis::Enum::X:
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->radius = _radius * std::max(_pose.scale.y, _pose.scale.z);
            break;
        case ColliderShapeUpAxis::Enum::Y:
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->radius = _radius * std::max(_pose.scale.x, _pose.scale.z);
            break;
        case ColliderShapeUpAxis::Enum::Z:
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->radius = _radius * std::max(_pose.scale.x, _pose.scale.y);
            break;
    }
    _nativeShape->setGeometry(*_nativeGeometry);
}

float CapsuleColliderShape::height() {
    return _height;
}

void CapsuleColliderShape::setHeight(float value) {
    _height = value * 0.5;
    switch (_upAxis) {
        case ColliderShapeUpAxis::Enum::X:
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->halfHeight = _height * _pose.scale.x;
            break;
        case ColliderShapeUpAxis::Enum::Y:
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->halfHeight = _height * _pose.scale.y;
            break;
        case ColliderShapeUpAxis::Enum::Z:
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->halfHeight = _height * _pose.scale.z;
            break;
    }
    _nativeShape->setGeometry(*_nativeGeometry);
}

ColliderShapeUpAxis::Enum CapsuleColliderShape::upAxis() {
    return _upAxis;
}

void CapsuleColliderShape::setUpAxis(ColliderShapeUpAxis::Enum value) {
    _upAxis = value;
    switch (_upAxis) {
        case ColliderShapeUpAxis::Enum::X:
            _pose.rotation = math::Quaternion(0, 0, 0, 1);
            break;
        case ColliderShapeUpAxis::Enum::Y:
            _pose.rotation = math::Quaternion(0, 0, ColliderShape::halfSqrt, ColliderShape::halfSqrt);
            break;
        case ColliderShapeUpAxis::Enum::Z:
            _pose.rotation = math::Quaternion(0, ColliderShape::halfSqrt, 0, ColliderShape::halfSqrt);
            break;
    }
    setLocalPose(_pose);
}

void CapsuleColliderShape::setWorldScale(const math::Float3 &scale) {
    switch (_upAxis) {
        case ColliderShapeUpAxis::Enum::X:
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->radius = _radius * std::max(scale.y, scale.z);
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->halfHeight = _height * scale.x;
            break;
        case ColliderShapeUpAxis::Enum::Y:
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->radius = _radius * std::max(scale.x, scale.z);
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->halfHeight = _height * scale.y;
            break;
        case ColliderShapeUpAxis::Enum::Z:
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->radius = _radius * std::max(scale.x, scale.y);
            static_cast<PxCapsuleGeometry *>(_nativeGeometry.get())->halfHeight = _height * scale.z;
            break;
    }
    _nativeShape->setGeometry(*_nativeGeometry);
}

}
}
