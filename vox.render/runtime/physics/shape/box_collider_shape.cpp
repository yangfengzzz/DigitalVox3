//
//  box_collider_shape.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#include "box_collider_shape.h"

namespace vox {
namespace physics {
BoxColliderShape::BoxColliderShape() {
    
}

math::Float3 BoxColliderShape::size() {
    const auto& extent = static_cast<PxBoxGeometry*>(_pxGeometry)->halfExtents;
    return math::Float3(extent.x, extent.y, extent.z);
}

void BoxColliderShape::setSize(const math::Float3& half) {
    static_cast<PxBoxGeometry*>(_pxGeometry)->halfExtents = PxVec3(half.x, half.y, half.z);
    _pxShape->setGeometry(*_pxGeometry);
}

}
}
