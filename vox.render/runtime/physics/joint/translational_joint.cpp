//
//  translational_joint.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "translational_joint.h"
#include "../physics_manager.h"
#include "../collider.h"

namespace vox {
namespace physics {
TranslationalJoint::TranslationalJoint(Collider* collider0, Collider* collider1) {
    _nativeJoint = PxPrismaticJointCreate(*PhysicsManager::_nativePhysics(), collider0->handle(), PxTransform(),
                                          collider1->handle(), PxTransform());
}

float TranslationalJoint::position() const {
    return static_cast<PxPrismaticJoint*>(_nativeJoint)->getPosition();
}

float TranslationalJoint::velocity() const {
    return static_cast<PxPrismaticJoint*>(_nativeJoint)->getVelocity();
}

void TranslationalJoint::setLimit(const PxJointLinearLimitPair &pair) {
    static_cast<PxPrismaticJoint*>(_nativeJoint)->setLimit(pair);
}

PxJointLinearLimitPair TranslationalJoint::limit() const {
    return static_cast<PxPrismaticJoint*>(_nativeJoint)->getLimit();
}

void TranslationalJoint::setPrismaticJointFlags(PxPrismaticJointFlags flags) {
    static_cast<PxPrismaticJoint*>(_nativeJoint)->setPrismaticJointFlags(flags);
}

void TranslationalJoint::setPrismaticJointFlag(PxPrismaticJointFlag::Enum flag, bool value) {
    static_cast<PxPrismaticJoint*>(_nativeJoint)->setPrismaticJointFlag(flag, value);
}

PxPrismaticJointFlags TranslationalJoint::translationalJointFlags() const {
    return static_cast<PxPrismaticJoint*>(_nativeJoint)->getPrismaticJointFlags();
}

void TranslationalJoint::setProjectionLinearTolerance(float tolerance) {
    static_cast<PxPrismaticJoint*>(_nativeJoint)->setProjectionLinearTolerance(tolerance);
}

float TranslationalJoint::projectionLinearTolerance() const {
    return static_cast<PxPrismaticJoint*>(_nativeJoint)->getProjectionLinearTolerance();
}

void TranslationalJoint::setProjectionAngularTolerance(float tolerance) {
    static_cast<PxPrismaticJoint*>(_nativeJoint)->setProjectionAngularTolerance(tolerance);
}

float TranslationalJoint::projectionAngularTolerance() const {
    return static_cast<PxPrismaticJoint*>(_nativeJoint)->getProjectionAngularTolerance();
}


}
}
