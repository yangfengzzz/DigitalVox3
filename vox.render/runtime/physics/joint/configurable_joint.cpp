//
//  configurable_joint.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "configurable_joint.h"
#include "../physics_manager.h"
#include "../collider.h"

namespace vox {
namespace physics {
ConfigurableJoint::ConfigurableJoint(Collider* collider0, Collider* collider1) {
    _nativeJoint = PxD6JointCreate(*PhysicsManager::_nativePhysics(), collider0->handle(), PxTransform(),
                                   collider1->handle(), PxTransform());
}

void ConfigurableJoint::setMotion(PxD6Axis::Enum axis, PxD6Motion::Enum type) {
    static_cast<PxD6Joint*>(_nativeJoint)->setMotion(axis, type);
}

PxD6Motion::Enum ConfigurableJoint::motion(PxD6Axis::Enum axis) const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getMotion(axis);
}

float ConfigurableJoint::twistAngle() const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getTwistAngle();
}

float ConfigurableJoint::swingYAngle() const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getSwingYAngle();
}

float ConfigurableJoint::swingZAngle() const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getSwingZAngle();
}

void ConfigurableJoint::setDistanceLimit(const PxJointLinearLimit &limit) {
    static_cast<PxD6Joint*>(_nativeJoint)->setDistanceLimit(limit);
}

PxJointLinearLimit ConfigurableJoint::distanceLimit() const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getDistanceLimit();
}

void ConfigurableJoint::setLinearLimit(PxD6Axis::Enum axis, const PxJointLinearLimitPair &limit) {
    static_cast<PxD6Joint*>(_nativeJoint)->setLinearLimit(axis, limit);
}

PxJointLinearLimitPair ConfigurableJoint::linearLimit(PxD6Axis::Enum axis) const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getLinearLimit(axis);
}

void ConfigurableJoint::setTwistLimit(const PxJointAngularLimitPair &limit) {
    static_cast<PxD6Joint*>(_nativeJoint)->setTwistLimit(limit);
}

PxJointAngularLimitPair ConfigurableJoint::twistLimit() const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getTwistLimit();
}

void ConfigurableJoint::setSwingLimit(const PxJointLimitCone &limit) {
    static_cast<PxD6Joint*>(_nativeJoint)->setSwingLimit(limit);
}

PxJointLimitCone ConfigurableJoint::swingLimit() const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getSwingLimit();
}

void ConfigurableJoint::pyramidSwingLimit(const PxJointLimitPyramid &limit) {
    static_cast<PxD6Joint*>(_nativeJoint)->setPyramidSwingLimit(limit);
}

PxJointLimitPyramid ConfigurableJoint::pyramidSwingLimit() const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getPyramidSwingLimit();
}

void ConfigurableJoint::setDrive(PxD6Drive::Enum index, const PxD6JointDrive &drive) {
    static_cast<PxD6Joint*>(_nativeJoint)->setDrive(index, drive);
}

PxD6JointDrive ConfigurableJoint::drive(PxD6Drive::Enum index) const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getDrive(index);
}

void ConfigurableJoint::setDrivePosition(const math::Transform &pose, bool autowake) {
    const auto& p = pose.translation;
    const auto& q = pose.rotation;
    
    static_cast<PxD6Joint*>(_nativeJoint)->setDrivePosition(PxTransform(PxVec3(p.x, p.y, p.z),
                                                                        PxQuat(q.x, q.y, q.z, q.w)), autowake);
}

math::Transform ConfigurableJoint::drivePosition() const {
    const auto pose = static_cast<PxD6Joint*>(_nativeJoint)->getDrivePosition();
    math::Transform trans;
    trans.translation = math::Float3(pose.p.x, pose.p.y, pose.p.z);
    trans.rotation = math::Quaternion(pose.q.x, pose.q.y, pose.q.z, pose.q.w);
    return trans;
}

void ConfigurableJoint::setDriveVelocity(const math::Float3 &linear, const math::Float3 &angular, bool autowake) {
    static_cast<PxD6Joint*>(_nativeJoint)->setDriveVelocity(PxVec3(linear.x, linear.y, linear.z),
                                                            PxVec3(angular.x, angular.y, angular.z), autowake);
}

void ConfigurableJoint::driveVelocity(math::Float3 &linear, math::Float3 &angular) const {
    PxVec3 l, a;
    static_cast<PxD6Joint*>(_nativeJoint)->getDriveVelocity(l, a);
    linear = math::Float3(l.x, l.y, l.z);
    angular = math::Float3(a.x, a.y, a.z);
}

void ConfigurableJoint::setProjectionLinearTolerance(float tolerance) {
    static_cast<PxD6Joint*>(_nativeJoint)->setProjectionLinearTolerance(tolerance);
}

float ConfigurableJoint::projectionLinearTolerance() const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getProjectionLinearTolerance();
}

void ConfigurableJoint::setProjectionAngularTolerance(float tolerance) {
    static_cast<PxD6Joint*>(_nativeJoint)->setProjectionAngularTolerance(tolerance);
}

float ConfigurableJoint::projectionAngularTolerance() const {
    return static_cast<PxD6Joint*>(_nativeJoint)->getProjectionAngularTolerance();
}

}
}
