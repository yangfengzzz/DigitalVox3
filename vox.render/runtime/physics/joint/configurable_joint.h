//
//  configurable_joint.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#ifndef configurable_joint_hpp
#define configurable_joint_hpp

#include "joint.h"

namespace vox {
namespace physics {
/**
 * A Configurable joint is a general constraint between two actors.
 */
class ConfigurableJoint : public Joint {
public:
    ConfigurableJoint(Collider *collider0, Collider *collider1);
    
    void setMotion(PxD6Axis::Enum axis, PxD6Motion::Enum type);
    
    PxD6Motion::Enum motion(PxD6Axis::Enum axis) const;
    
    float twistAngle() const;
    
    float swingYAngle() const;
    
    float swingZAngle() const;
    
public:
    void setDistanceLimit(const PxJointLinearLimit &limit);
    
    PxJointLinearLimit distanceLimit() const;
    
    void setLinearLimit(PxD6Axis::Enum axis, const PxJointLinearLimitPair &limit);
    
    PxJointLinearLimitPair linearLimit(PxD6Axis::Enum axis) const;
    
    void setTwistLimit(const PxJointAngularLimitPair &limit);
    
    PxJointAngularLimitPair twistLimit() const;
    
    void setSwingLimit(const PxJointLimitCone &limit);
    
    PxJointLimitCone swingLimit() const;
    
    void pyramidSwingLimit(const PxJointLimitPyramid &limit);
    
    PxJointLimitPyramid pyramidSwingLimit() const;
    
public:
    void setDrive(PxD6Drive::Enum index, const PxD6JointDrive &drive);
    
    PxD6JointDrive drive(PxD6Drive::Enum index) const;
    
    void setDrivePosition(const math::Transform &pose, bool autowake = true);
    
    math::Transform drivePosition() const;
    
    void setDriveVelocity(const math::Float3 &linear, const math::Float3 &angular, bool autowake = true);
    
    void driveVelocity(math::Float3 &linear, math::Float3 &angular) const;
    
    void setProjectionLinearTolerance(float tolerance);
    
    float projectionLinearTolerance() const;
    
    void setProjectionAngularTolerance(float tolerance);
    
    float projectionAngularTolerance() const;
};
}
}
#endif /* configurable_joint_hpp */
