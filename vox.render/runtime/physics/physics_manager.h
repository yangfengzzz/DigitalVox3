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

namespace vox {
namespace physics {
/// A physics manager is a collection of bodies and constraints which can interact.
class PhysicsManager {
public:
    static size_t _idGenerator;
    static Physics _nativePhysics;
    
    PhysicsManager();
    
private:
    PxControllerManager* _nativeCharacterControllerManager;
    PxScene* _nativePhysicsManager;
    
    std::unordered_map<uint32_t, ColliderShapePtr> _physicalObjectsMap;
    
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
