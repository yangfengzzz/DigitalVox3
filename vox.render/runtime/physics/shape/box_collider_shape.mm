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
    _nativeShape->setQueryFilterData(PxFilterData(static_cast<uint32_t>(PhysicsManager::_idGenerator++), 0, 0, 0));
}

math::Float3 BoxColliderShape::size() {
    const auto& extent = static_cast<PxBoxGeometry*>(_nativeGeometry)->halfExtents;
    return math::Float3(extent.x, extent.y, extent.z);
}

void BoxColliderShape::setSize(const math::Float3& half) {
    static_cast<PxBoxGeometry*>(_nativeGeometry)->halfExtents = PxVec3(half.x, half.y, half.z);
    _nativeShape->setGeometry(*_nativeGeometry);
}

}
}
