//
//  dynamic_collider.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "dynamic_collider.h"
#include "physics_manager.h"
#include "../entity.h"

namespace vox {
namespace physics {
DynamicCollider::DynamicCollider(Entity* entity):
Collider(entity) {
    const auto& p = entity->transform->worldPosition();
    const auto& q = entity->transform->worldRotationQuaternion();
    
    _nativeActor = PhysicsManager::_nativePhysics()->createRigidDynamic(PxTransform(PxVec3(p.x, p.y, p.z),
                                                                                    PxQuat(q.x, q.y, q.z, q.w)));
}

}
}
