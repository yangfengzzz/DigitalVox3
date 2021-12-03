//
//  spherical_joint.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "spherical_joint.h"
#include "../physics_manager.h"
#include "../collider.h"

namespace vox {
namespace physics {
SphericalJoint::SphericalJoint(Collider* collider0, Collider* collider1) {
    _nativeJoint = PxSphericalJointCreate(*PhysicsManager::_nativePhysics(), collider0->handle(), PxTransform(),
                                          collider1->handle(), PxTransform());
}

PxJointLimitCone SphericalJoint::limitCone() const {
    return static_cast<PxSphericalJoint*>(_nativeJoint)->getLimitCone();
}

void SphericalJoint::setLimitCone(const PxJointLimitCone &limit) {
    static_cast<PxSphericalJoint*>(_nativeJoint)->setLimitCone(limit);
}

float SphericalJoint::swingYAngle() const {
    return static_cast<PxSphericalJoint*>(_nativeJoint)->getSwingYAngle();
}

float SphericalJoint::swingZAngle() const {
    return static_cast<PxSphericalJoint*>(_nativeJoint)->getSwingZAngle();
}

void SphericalJoint::setSphericalJointFlags(PxSphericalJointFlags flags) {
    static_cast<PxSphericalJoint*>(_nativeJoint)->setSphericalJointFlags(flags);
}

void SphericalJoint::setSphericalJointFlag(PxSphericalJointFlag::Enum flag, bool value) {
    static_cast<PxSphericalJoint*>(_nativeJoint)->setSphericalJointFlag(flag, value);
}

PxSphericalJointFlags SphericalJoint::sphericalJointFlags() const {
    return static_cast<PxSphericalJoint*>(_nativeJoint)->getSphericalJointFlags();
}

void SphericalJoint::setProjectionLinearTolerance(float tolerance) {
    static_cast<PxSphericalJoint*>(_nativeJoint)->setProjectionLinearTolerance(tolerance);
}

float SphericalJoint::projectionLinearTolerance() const {
    return static_cast<PxSphericalJoint*>(_nativeJoint)->getProjectionLinearTolerance();
}


}
}
