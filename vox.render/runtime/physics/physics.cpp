//
//  physics.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#include "physics.h"
#include "physics_material.h"

namespace vox {
namespace physics {
Physics::Physics() {
    PxFoundation *gFoundation = PxCreateFoundation(PX_PHYSICS_VERSION, gAllocator, gErrorCallback);
    _physics = PxCreatePhysics(PX_PHYSICS_VERSION, *gFoundation, PxTolerancesScale(), false, nullptr);
}

PhysicsMaterial Physics::createMaterial(PxReal staticFriction, PxReal dynamicFriction, PxReal restitution) {
    return PhysicsMaterial(_physics->createMaterial(staticFriction, dynamicFriction, restitution));
}

}
}
