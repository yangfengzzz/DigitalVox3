//
//  box_collider_shape.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#include "box_collider_shape.h"
#include "../physics_manager.h"

namespace vox {
namespace physics {
BoxColliderShape::BoxColliderShape():ColliderShape() {
    _nativeGeometry = new PxBoxGeometry();
    _nativeShape = PhysicsManager::_nativePhysics()->createShape(*_nativeGeometry, *_nativeMaterial);
    _nativeShape->setQueryFilterData(PxFilterData(PhysicsManager::_idGenerator++, 0, 0, 0));
}

math::Float3 BoxColliderShape::size() {
    return _half;
}

void BoxColliderShape::setSize(const math::Float3& half) {
    _half = half;
    auto halfExtent = _half * _pose.scale;
    static_cast<PxBoxGeometry*>(_nativeGeometry)->halfExtents = PxVec3(halfExtent.x, halfExtent.y, halfExtent.z);
    _nativeShape->setGeometry(*_nativeGeometry);
}

void BoxColliderShape::setWorldScale(const math::Float3& scale) {
    _pose.scale = scale;
    auto halfExtent = _half * _pose.scale;
    static_cast<PxBoxGeometry*>(_nativeGeometry)->halfExtents = PxVec3(halfExtent.x, halfExtent.y, halfExtent.z);
    _nativeShape->setGeometry(*_nativeGeometry);
}

}
}
