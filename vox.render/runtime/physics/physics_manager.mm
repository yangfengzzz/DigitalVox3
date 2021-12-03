//
//  physics_manager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "physics_manager.h"
#include "shape/collider_shape.h"
#include "collider.h"
#include "../entity.h"

namespace vox {
namespace physics {
namespace {
class PxSimulationEventCallbackWrapper : public PxSimulationEventCallback {
public:
    std::function<void(PxShape *obj1, PxShape *obj2)> onContactEnter;
    std::function<void(PxShape *obj1, PxShape *obj2)> onContactExit;
    std::function<void(PxShape *obj1, PxShape *obj2)> onContactStay;
    
    std::function<void(PxShape *obj1, PxShape *obj2)> onTriggerEnter;
    std::function<void(PxShape *obj1, PxShape *obj2)> onTriggerExit;
    std::function<void(PxShape *obj1, PxShape *obj2)> onTriggerStay;
    
    PxSimulationEventCallbackWrapper(std::function<void(PxShape *obj1, PxShape *obj2)> onContactEnter,
                                     std::function<void(PxShape *obj1, PxShape *obj2)> onContactExit,
                                     std::function<void(PxShape *obj1, PxShape *obj2)> onContactStay,
                                     std::function<void(PxShape *obj1, PxShape *obj2)> onTriggerEnter,
                                     std::function<void(PxShape *obj1, PxShape *obj2)> onTriggerExit,
                                     std::function<void(PxShape *obj1, PxShape *obj2)> onTriggerStay) :
    onContactEnter(onContactEnter), onContactExit(onContactExit), onContactStay(onContactStay),
    onTriggerEnter(onTriggerEnter), onTriggerExit(onTriggerExit), onTriggerStay(onTriggerStay) {
    }
    
    void onConstraintBreak(PxConstraintInfo *, PxU32) override {
    }
    
    void onWake(PxActor **, PxU32) override {
    }
    
    void onSleep(PxActor **, PxU32) override {
    }
    
    void onContact(const PxContactPairHeader &, const PxContactPair *pairs, PxU32 nbPairs) override {
        for (PxU32 i = 0; i < nbPairs; i++) {
            const PxContactPair &cp = pairs[i];
            
            if (cp.events & (PxPairFlag::eNOTIFY_TOUCH_FOUND | PxPairFlag::eNOTIFY_TOUCH_CCD)) {
                onContactEnter(cp.shapes[0], cp.shapes[1]);
            } else if (cp.events & PxPairFlag::eNOTIFY_TOUCH_LOST) {
                onContactExit(cp.shapes[0], cp.shapes[1]);
            } else if (cp.events & PxPairFlag::eNOTIFY_TOUCH_PERSISTS) {
                onContactStay(cp.shapes[0], cp.shapes[1]);
            }
        }
    }
    
    void onTrigger(PxTriggerPair *pairs, PxU32 count) override {
        for (PxU32 i = 0; i < count; i++) {
            const PxTriggerPair &tp = pairs[i];
            
            if (tp.status & PxPairFlag::eNOTIFY_TOUCH_FOUND) {
                onTriggerEnter(tp.triggerShape, tp.otherShape);
            } else if (tp.status & PxPairFlag::eNOTIFY_TOUCH_LOST) {
                onTriggerExit(tp.triggerShape, tp.otherShape);
            }
        }
    }
    
    void onAdvance(const PxRigidBody *const *, const PxTransform *, const PxU32) override {
    }
};
} // namespace

uint32_t PhysicsManager::_idGenerator = 0;
Physics PhysicsManager::_nativePhysics = Physics();
PhysicsManager::PhysicsManager(){
    onContactEnter = [&](PxShape *obj1, PxShape *obj2) { };
    onContactExit = [&](PxShape *obj1, PxShape *obj2) { };
    onContactStay = [&](PxShape *obj1, PxShape *obj2) { };
    
    onTriggerEnter = [&](PxShape *obj1, PxShape *obj2) {
        const auto shape1 = _physicalObjectsMap[obj1->getQueryFilterData().word0];
        const auto shape2 = _physicalObjectsMap[obj2->getQueryFilterData().word0];
        
        auto scripts = shape1->collider()->entity()->scripts();
        for (const auto& script : scripts) {
            script->onTriggerEnter(shape2.get());
        }
        
        scripts = shape2->collider()->entity()->scripts();
        for (const auto& script : scripts) {
            script->onTriggerEnter(shape1.get());
        }
    };
    onTriggerExit = [&](PxShape *obj1, PxShape *obj2) {
        const auto shape1 = _physicalObjectsMap[obj1->getQueryFilterData().word0];
        const auto shape2 = _physicalObjectsMap[obj2->getQueryFilterData().word0];
        
        auto scripts = shape1->collider()->entity()->scripts();
        for (const auto& script : scripts) {
            script->onTriggerExit(shape2.get());
        }
        
        scripts = shape2->collider()->entity()->scripts();
        for (const auto& script : scripts) {
            script->onTriggerExit(shape1.get());
        }
    };
    onTriggerStay = [&](PxShape *obj1, PxShape *obj2) { };
    
    PxSimulationEventCallbackWrapper *simulationEventCallback =
    new PxSimulationEventCallbackWrapper(onContactEnter, onContactExit, onContactStay,
                                         onTriggerEnter, onTriggerExit, onTriggerStay);
    
    PxSceneDesc sceneDesc(_nativePhysics()->getTolerancesScale());
    sceneDesc.gravity = PxVec3(0.0f, -9.81f, 0.0f);
    sceneDesc.cpuDispatcher = PxDefaultCpuDispatcherCreate(1);
    sceneDesc.filterShader = PxDefaultSimulationFilterShader;
    sceneDesc.simulationEventCallback = simulationEventCallback;
    sceneDesc.kineKineFilteringMode = PxPairFilteringMode::eKEEP;
    sceneDesc.staticKineFilteringMode = PxPairFilteringMode::eKEEP;
    sceneDesc.flags |= PxSceneFlag::eENABLE_CCD;
    
    _nativePhysicsManager = _nativePhysics()->createScene(sceneDesc);
    _nativeCharacterControllerManager = PxCreateControllerManager(*_nativePhysicsManager);
}

void PhysicsManager::update(float deltaTime) {
    _nativePhysicsManager->simulate(deltaTime);
    _nativePhysicsManager->fetchResults(true);
}

void PhysicsManager::callColliderOnUpdate() {
    for (auto& collider : _colliders) {
        collider->_onUpdate();
    }
}

void PhysicsManager::callColliderOnLateUpdate() {
    for (auto& collider : _colliders) {
        collider->_onLateUpdate();
    }
}

void PhysicsManager::callCharacterControllerOnLateUpdate() {
    
}

void PhysicsManager::_addColliderShape(const ColliderShapePtr& colliderShape) {
    _physicalObjectsMap[colliderShape->uniqueID()] = (colliderShape);
}

void PhysicsManager::_removeColliderShape(const ColliderShapePtr& colliderShape) {
    _physicalObjectsMap.erase(colliderShape->uniqueID());
}

void PhysicsManager::_addCollider(Collider* collider) {
    _colliders.push_back(collider);
    _nativePhysicsManager->addActor(*collider->_nativeActor);
}

void PhysicsManager::_removeCollider(Collider* collider) {
    auto iter = std::find(_colliders.begin(), _colliders.end(), collider);
    if (iter != _colliders.end()) {
        _colliders.erase(iter);
    }
    
    _nativePhysicsManager->removeActor(*collider->_nativeActor);
}

//MARK: - Raycast
bool PhysicsManager::raycast(const math::Ray& ray) {
    return _raycast(ray, std::numeric_limits<float>::infinity(), nullptr);
}

bool PhysicsManager::raycast(const math::Ray& ray, HitResult& outHitResult) {
    const auto layerMask = Layer::Everything;
    
    bool result = false;
    _raycast(ray, std::numeric_limits<float>::infinity(),
             [&](uint32_t idx, float distance, const math::Float3& normal, const math::Float3& point) {
        if (_physicalObjectsMap[idx]->collider()->entity()->layer & layerMask) {
            result = true;
            
            outHitResult.entity = _physicalObjectsMap[idx]->collider()->entity();
            outHitResult.distance = distance;
            outHitResult.normal = normal;
            outHitResult.point = point;
        }
    });
    
    if (!result) {
        outHitResult.entity = nullptr;
        outHitResult.distance = 0;
        outHitResult.point = math::Float3(0, 0, 0);
        outHitResult.normal = math::Float3(0, 0, 0);
    }
    
    return result;
}

bool PhysicsManager::raycast(const math::Ray& ray, float distance) {
    return _raycast(ray, distance, nullptr);
}

bool PhysicsManager::raycast(const math::Ray& ray, float distance, HitResult&  outHitResult) {
    const auto layerMask = Layer::Everything;
    
    bool result = false;
    _raycast(ray, distance, [&](uint32_t idx, float distance, const math::Float3& normal, const math::Float3& point) {
        if (_physicalObjectsMap[idx]->collider()->entity()->layer & layerMask) {
            result = true;
            
            outHitResult.entity = _physicalObjectsMap[idx]->collider()->entity();
            outHitResult.distance = distance;
            outHitResult.normal = normal;
            outHitResult.point = point;
        }
    });
    
    if (!result) {
        outHitResult.entity = nullptr;
        outHitResult.distance = 0;
        outHitResult.point = math::Float3(0, 0, 0);
        outHitResult.normal = math::Float3(0, 0, 0);
    }
    
    return result;
}

bool PhysicsManager::raycast(const math::Ray& ray, float distance, Layer layerMask) {
    bool result = false;
    _raycast(ray, distance, [&](uint32_t idx, float, const math::Float3&, const math::Float3&) {
        if (_physicalObjectsMap[idx]->collider()->entity()->layer & layerMask) {
            result = true;
        }
    });
    return result;
}

bool PhysicsManager::raycast(const math::Ray& ray, float distance, Layer layerMask, HitResult&  outHitResult) {
    bool result = false;
    _raycast(ray, distance, [&](uint32_t idx, float distance, const math::Float3& normal, const math::Float3& point) {
        if (_physicalObjectsMap[idx]->collider()->entity()->layer & layerMask) {
            result = true;
            
            outHitResult.entity = _physicalObjectsMap[idx]->collider()->entity();
            outHitResult.distance = distance;
            outHitResult.normal = normal;
            outHitResult.point = point;
        }
    });
    
    if (!result) {
        outHitResult.entity = nullptr;
        outHitResult.distance = 0;
        outHitResult.point = math::Float3(0, 0, 0);
        outHitResult.normal = math::Float3(0, 0, 0);
    }
    
    return result;
}

bool PhysicsManager::_raycast(const math::Ray& ray, float distance,
                              std::function<void(uint32_t, float,
                                                 const math::Float3&,
                                                 const math::Float3&)> outHitResult) {
    PxRaycastHit hit = PxRaycastHit();
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC);
    
    const auto& origin = ray.origin;
    const auto& direction = ray.direction;
    bool result = PxSceneQueryExt::raycastSingle(*_nativePhysicsManager,
                                                 PxVec3(origin.x, origin.y, origin.z),
                                                 PxVec3(direction.x, direction.y, direction.z),
                                                 distance, PxHitFlags(PxHitFlag::eDEFAULT),
                                                 hit, filterData);
    
    if (result && outHitResult != nullptr) {
        outHitResult(hit.shape->getQueryFilterData().word0,
                     hit.distance,
                     math::Float3(hit.position.x, hit.position.y, hit.position.z),
                     math::Float3(hit.normal.x, hit.normal.y, hit.normal.z));
    }
    
    return result;
}

}
}
