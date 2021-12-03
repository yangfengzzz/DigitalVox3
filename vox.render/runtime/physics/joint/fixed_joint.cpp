//
//  fixed_joint.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "fixed_joint.h"
#include "../physics_manager.h"
#include "../collider.h"

namespace vox {
namespace physics {
FixedJoint::FixedJoint(Collider* collider0, Collider* collider1) {
    _nativeJoint = PxFixedJointCreate(*PhysicsManager::_nativePhysics(), collider0->handle(), PxTransform(), collider1->handle(), PxTransform());
}

void FixedJoint::setProjectionLinearTolerance(float tolerance) {
    return static_cast<PxFixedJoint*>(_nativeJoint)->setProjectionLinearTolerance(tolerance);
}

float FixedJoint::projectionLinearTolerance() const {
    return static_cast<PxFixedJoint*>(_nativeJoint)->getProjectionLinearTolerance();
}

void FixedJoint::setProjectionAngularTolerance(float tolerance) {
    return static_cast<PxFixedJoint*>(_nativeJoint)->setProjectionAngularTolerance(tolerance);
}

float FixedJoint::projectionAngularTolerance() const {
    return static_cast<PxFixedJoint*>(_nativeJoint)->getProjectionAngularTolerance();
}

}
}
