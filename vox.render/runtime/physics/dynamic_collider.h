//
//  dynamic_collider.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#ifndef dynamic_collider_hpp
#define dynamic_collider_hpp

#include "collider.h"
#include "maths/transform.h"

namespace vox {
namespace physics {
class DynamicCollider: public Collider {
public:
    DynamicCollider(Entity* entity);
    
    /**
     * The linear damping of the dynamic collider.
     */
    float linearDamping();

    void setLinearDamping(float newValue);
    
    /**
     * The angular damping of the dynamic collider.
     */
    float angularDamping();

    void setAngularDamping(float newValue);

    /**
     * The linear velocity vector of the dynamic collider measured in world unit per second.
     */
    math::Float3 linearVelocity();

    void setLinearVelocity(const math::Float3& newValue);

    /**
     * The angular velocity vector of the dynamic collider measured in radians per second.
     */
    math::Float3 angularVelocity();

    void setAngularVelocity(const math::Float3& newValue);

    /**
     * The mass of the dynamic collider.
     */
    float mass();

    void setMass(float newValue);

    /**
     * The center of mass relative to the transform's origin.
     */
    math::Transform centerOfMass();

    void setCenterOfMass(const math::Transform& newValue);

    /**
     * The diagonal inertia tensor of mass relative to the center of mass.
     */
    math::Float3 inertiaTensor();

    void setInertiaTensor(const math::Float3& newValue);

    /**
     * The maximum angular velocity of the collider measured in radians per second. (Default 7) range { 0, infinity }.
     */
    float maxAngularVelocity();

    void setMaxAngularVelocity(float newValue);

    /**
     * Maximum velocity of a collider when moving out of penetrating state.
     */
    float maxDepenetrationVelocity();

    void setMaxDepenetrationVelocity(float newValue);

    /**
     * The mass-normalized energy threshold, below which objects start going to sleep.
     */
    float sleepThreshold();

    void setSleepThreshold(float newValue);

    /**
     * The solverIterations determines how accurately collider joints and collision contacts are resolved.
     */
    uint32_t solverIterations();

    void setSolverIterations(uint32_t newValue);

    /**
     * Controls whether physics affects the dynamic collider.
     */
    bool isKinematic();

    void setIsKinematic(bool newValue);

public:
    /**
     * Controls whether physics will change the rotation of the object.
     */
    bool freezeRotation();

    void setFreezeRotation(bool newValue);

    /**
     * The particular rigid dynamic lock flag.
     */
    PxRigidDynamicLockFlags rigidDynamicLockFlags() const;

    void setRigidDynamicLockFlag(PxRigidDynamicLockFlag::Enum flag, bool value);
    
    void setRigidDynamicLockFlags(PxRigidDynamicLockFlags flags);
    
public:
    
};

}
}

#endif /* dynamic_collider_hpp */
