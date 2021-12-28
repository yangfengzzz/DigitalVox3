//
//  plane_collider_shape.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "plane_collider_shape.h"
#include "../physics_manager.h"

namespace vox {
namespace physics {
PlaneColliderShape::PlaneColliderShape() {
    _nativeGeometry = std::make_shared<PxPlaneGeometry>();
    _nativeShape = PhysicsManager::_nativePhysics()->createShape(*_nativeGeometry, *_nativeMaterial, true);
    _nativeShape->setQueryFilterData(PxFilterData(PhysicsManager::_idGenerator++, 0, 0, 0));
    setLocalPose(_pose);
}

math::Float3 PlaneColliderShape::rotation() {
    const auto &rot = _pose.rotation;
    return math::ToEuler(rot);
}

void PlaneColliderShape::setRotation(const math::Float3 &value) {
    _pose.rotation = math::Quaternion::FromEuler(value.x, value.y, value.z);
    _pose.rotation = math::Quaternion::rotateZ(_pose.rotation, M_PI * 0.5);
    _pose.rotation = math::Normalize(_pose.rotation);
    setLocalPose(_pose);
}

}
}
