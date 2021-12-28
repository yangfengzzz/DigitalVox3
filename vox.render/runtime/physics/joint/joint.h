//
//  joint.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#ifndef joint_hpp
#define joint_hpp

#include "../physics.h"
#include "maths/transform.h"

namespace vox {
namespace physics {
/**
 * A base class providing common functionality for joints.
 */
class Joint {
public:
    void setActors(Collider *actor0, Collider *actor1);
    
    void setLocalPose(PxJointActorIndex::Enum actor, const math::Transform &localPose);
    
    math::Transform localPose(PxJointActorIndex::Enum actor) const;
    
    math::Transform relativeTransform() const;
    
    math::Float3 relativeLinearVelocity() const;
    
    math::Float3 relativeAngularVelocity() const;
    
    void setBreakForce(float force, float torque);
    
    void getBreakForce(float &force, float &torque) const;
    
    void setConstraintFlags(PxConstraintFlags flags);
    
    void setConstraintFlag(PxConstraintFlag::Enum flag, bool value);
    
    PxConstraintFlags constraintFlags() const;
    
    void setInvMassScale0(float invMassScale);
    
    float invMassScale0() const;
    
    void setInvInertiaScale0(float invInertiaScale);
    
    float invInertiaScale0() const;
    
    void setInvMassScale1(float invMassScale);
    
    float invMassScale1() const;
    
    void setInvInertiaScale1(float invInertiaScale);
    
    float invInertiaScale1() const;
    
protected:
    PxJoint *_nativeJoint;
};

}
}

#endif /* joint_hpp */
