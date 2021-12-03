//
//  physics_manager.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#ifndef physics_manager_hpp
#define physics_manager_hpp

#include "physics.h"
#include <unordered_map>
#include <vector>
#include "maths/ray.h"
#include "hit_result.h"
#include "../layer.h"

namespace vox {
namespace physics {
/**
 * A physics manager is a collection of bodies and constraints which can interact.
 */
class PhysicsManager {
public:
    static uint32_t _idGenerator;
    static Physics _nativePhysics;
    
    PhysicsManager();
    
public:
    /**
     * Casts a ray through the Scene and returns the first hit.
     * @param ray - The ray
     * @returns Returns True if the ray intersects with a collider, otherwise false
     */
    bool raycast(const math::Ray& ray);
    
    /**
     * Casts a ray through the Scene and returns the first hit.
     * @param ray - The ray
     * @param outHitResult - If true is returned, outHitResult will contain more detailed collision information
     * @returns Returns True if the ray intersects with a collider, otherwise false
     */
    bool raycast(const math::Ray& ray, HitResult& outHitResult);
    
    /**
     * Casts a ray through the Scene and returns the first hit.
     * @param ray - The ray
     * @param distance - The max distance the ray should check
     * @returns Returns True if the ray intersects with a collider, otherwise false
     */
    bool raycast(const math::Ray& ray, float distance);
    
    /**
     * Casts a ray through the Scene and returns the first hit.
     * @param ray - The ray
     * @param distance - The max distance the ray should check
     * @param outHitResult - If true is returned, outHitResult will contain more detailed collision information
     * @returns Returns True if the ray intersects with a collider, otherwise false
     */
    bool raycast(const math::Ray& ray, float distance, HitResult&  outHitResult);
    
    /**
     * Casts a ray through the Scene and returns the first hit.
     * @param ray - The ray
     * @param distance - The max distance the ray should check
     * @param layerMask - Layer mask that is used to selectively ignore Colliders when casting
     * @returns Returns True if the ray intersects with a collider, otherwise false
     */
    bool raycast(const math::Ray& ray, float distance, Layer layerMask);
    
    /**
     * Casts a ray through the Scene and returns the first hit.
     * @param ray - The ray
     * @param distance - The max distance the ray should check
     * @param layerMask - Layer mask that is used to selectively ignore Colliders when casting
     * @param outHitResult - If true is returned, outHitResult will contain more detailed collision information
     * @returns Returns True if the ray intersects with a collider, otherwise false.
     */
    bool raycast(const math::Ray& ray, float distance, Layer layerMask, HitResult&  outHitResult);
    
public:
    /**
     * Call on every frame to update pose of objects.
     */
    void update(float deltaTime);
    
    void callColliderOnUpdate();
    
    void callColliderOnLateUpdate();
    
    void callCharacterControllerOnLateUpdate();
    
private:
    friend class Collider;
    /**
     * Add ColliderShape into the manager.
     * @param colliderShape - The Collider Shape.
     */
    void _addColliderShape(const ColliderShapePtr& colliderShape);
    
    /**
     * Remove ColliderShape.
     * @param colliderShape - The Collider Shape.
     */
    void _removeColliderShape(const ColliderShapePtr& colliderShape);
    
    /**
     * Add collider into the manager.
     * @param collider - StaticCollider or DynamicCollider.
     */
    void _addCollider(Collider* collider);
    
    /**
     * Remove collider.
     * @param collider - StaticCollider or DynamicCollider.
     */
    void _removeCollider(Collider* collider);
    
    bool _raycast(const math::Ray& ray, float distance,
                  std::function<void(uint32_t, float,
                                     const math::Float3&,
                                     const math::Float3&)> outHitResult);
    
private:
    PxControllerManager* _nativeCharacterControllerManager;
    PxScene* _nativePhysicsManager;
    
    std::unordered_map<uint32_t, ColliderShapePtr> _physicalObjectsMap;
    std::vector<Collider*> _colliders;
    
    std::function<void(PxShape *obj1, PxShape *obj2)> onContactEnter;
    std::function<void(PxShape *obj1, PxShape *obj2)> onContactExit;
    std::function<void(PxShape *obj1, PxShape *obj2)> onContactStay;
    
    std::function<void(PxShape *obj1, PxShape *obj2)> onTriggerEnter;
    std::function<void(PxShape *obj1, PxShape *obj2)> onTriggerExit;
    std::function<void(PxShape *obj1, PxShape *obj2)> onTriggerStay;
};

}
}

#endif /* physics_manager_hpp */
