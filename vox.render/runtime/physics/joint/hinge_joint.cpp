//
//  hinge_joint.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "hinge_joint.h"
#include "../physics_manager.h"
#include "../collider.h"

namespace vox {
namespace physics {
HingeJoint::HingeJoint(Collider* collider0, Collider* collider1) {
    _nativeJoint = PxRevoluteJointCreate(*PhysicsManager::_nativePhysics(), collider0->handle(), PxTransform(),
                                          collider1->handle(), PxTransform());
}

float HingeJoint::angle() const {
    return static_cast<PxRevoluteJoint*>(_nativeJoint)->getAngle();
}

float HingeJoint::velocity() const {
    return static_cast<PxRevoluteJoint*>(_nativeJoint)->getVelocity();
}

void HingeJoint::setLimit(const PxJointAngularLimitPair &limits) {
    static_cast<PxRevoluteJoint*>(_nativeJoint)->setLimit(limits);
}

PxJointAngularLimitPair HingeJoint::limit() const {
    return static_cast<PxRevoluteJoint*>(_nativeJoint)->getLimit();
}

void HingeJoint::setDriveVelocity(float velocity, bool autowake) {
    static_cast<PxRevoluteJoint*>(_nativeJoint)->setDriveVelocity(velocity, autowake);
}

float HingeJoint::driveVelocity() const {
    return static_cast<PxRevoluteJoint*>(_nativeJoint)->getDriveVelocity();
}

void HingeJoint::setDriveForceLimit(float limit) {
    static_cast<PxRevoluteJoint*>(_nativeJoint)->setDriveForceLimit(limit);
}

float HingeJoint::driveForceLimit() const {
    return static_cast<PxRevoluteJoint*>(_nativeJoint)->getDriveForceLimit();
}

void HingeJoint::setDriveGearRatio(float ratio) {
    static_cast<PxRevoluteJoint*>(_nativeJoint)->setDriveGearRatio(ratio);
}

float HingeJoint::driveGearRatio() const {
    return static_cast<PxRevoluteJoint*>(_nativeJoint)->getDriveGearRatio();
}

void HingeJoint::setRevoluteJointFlags(PxRevoluteJointFlags flags) {
    static_cast<PxRevoluteJoint*>(_nativeJoint)->setRevoluteJointFlags(flags);
}

void HingeJoint::setRevoluteJointFlag(PxRevoluteJointFlag::Enum flag, bool value) {
    static_cast<PxRevoluteJoint*>(_nativeJoint)->setRevoluteJointFlag(flag, value);
}

PxRevoluteJointFlags HingeJoint::revoluteJointFlags() const {
    return static_cast<PxRevoluteJoint*>(_nativeJoint)->getRevoluteJointFlags();
}

void HingeJoint::setProjectionLinearTolerance(float tolerance) {
    static_cast<PxRevoluteJoint*>(_nativeJoint)->setProjectionLinearTolerance(tolerance);
}

float HingeJoint::projectionLinearTolerance() const {
    return static_cast<PxRevoluteJoint*>(_nativeJoint)->getProjectionLinearTolerance();
}

void HingeJoint::setProjectionAngularTolerance(float tolerance) {
    static_cast<PxRevoluteJoint*>(_nativeJoint)->setProjectionAngularTolerance(tolerance);
}

float HingeJoint::projectionAngularTolerance() const {
    return static_cast<PxRevoluteJoint*>(_nativeJoint)->getProjectionAngularTolerance();
}

}
}
