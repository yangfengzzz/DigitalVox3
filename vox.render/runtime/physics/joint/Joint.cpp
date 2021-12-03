//
//  Joint.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "Joint.h"
#include "../collider.h"

namespace vox {
namespace physics {
void Joint::setActors(Collider *actor0, Collider *actor1) {
    _nativeJoint->setActors(actor0->_nativeActor, actor1->_nativeActor);
}

void Joint::setLocalPose(PxJointActorIndex::Enum actor, const math::Transform &localPose) {
    const auto& p = localPose.translation;
    const auto& q = localPose.rotation;
    _nativeJoint->setLocalPose(actor, PxTransform(PxVec3(p.x, p.y, p.z), PxQuat(q.x, q.y, q.z, q.w)));
}

math::Transform Joint::localPose(PxJointActorIndex::Enum actor) const {
    const auto pose = _nativeJoint->getLocalPose(actor);
    math::Transform trans;
    trans.translation = math::Float3(pose.p.x, pose.p.y, pose.p.z);
    trans.rotation = math::Quaternion(pose.q.x, pose.q.y, pose.q.z, pose.q.w);
    return trans;
}

math::Transform Joint::relativeTransform() const {
    const auto pose = _nativeJoint->getRelativeTransform();
    math::Transform trans;
    trans.translation = math::Float3(pose.p.x, pose.p.y, pose.p.z);
    trans.rotation = math::Quaternion(pose.q.x, pose.q.y, pose.q.z, pose.q.w);
    return trans;
}

math::Float3 Joint::relativeLinearVelocity() const {
    const auto vel = _nativeJoint->getRelativeLinearVelocity();
    return math::Float3(vel.x, vel.y, vel.z);
}

math::Float3 Joint::relativeAngularVelocity() const {
    const auto vel = _nativeJoint->getRelativeAngularVelocity();
    return math::Float3(vel.x, vel.y, vel.z);
}

void Joint::setBreakForce(float force, float torque) {
    _nativeJoint->setBreakForce(force, torque);
}

void Joint::getBreakForce(float &force, float &torque) const {
    _nativeJoint->getBreakForce(force, torque);
}

void Joint::setConstraintFlags(PxConstraintFlags flags) {
    _nativeJoint->setConstraintFlags(flags);
}

void Joint::setConstraintFlag(PxConstraintFlag::Enum flag, bool value) {
    _nativeJoint->setConstraintFlag(flag, value);
}

PxConstraintFlags Joint::constraintFlags() const {
    return _nativeJoint->getConstraintFlags();
}

void Joint::setInvMassScale0(float invMassScale) {
    _nativeJoint->setInvMassScale0(invMassScale);
}

float Joint::invMassScale0() const {
    return _nativeJoint->getInvMassScale0();
}

void Joint::setInvInertiaScale0(float invInertiaScale) {
    _nativeJoint->setInvInertiaScale0(invInertiaScale);
}

float Joint::invInertiaScale0() const {
    return _nativeJoint->getInvInertiaScale0();
}

void Joint::setInvMassScale1(float invMassScale) {
    _nativeJoint->setInvMassScale1(invMassScale);
}

float Joint::invMassScale1() const {
    return _nativeJoint->getInvMassScale1();
}

void Joint::setInvInertiaScale1(float invInertiaScale) {
    _nativeJoint->setInvInertiaScale1(invInertiaScale);
}

float Joint::invInertiaScale1() const {
    return _nativeJoint->getInvInertiaScale1();
}

}
}
