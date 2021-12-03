//
//  physics_manager.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#ifndef physics_manager_hpp
#define physics_manager_hpp

#include "physics.h"

namespace vox {
namespace physics {
/// A physics manager is a collection of bodies and constraints which can interact.
class PhysicsManager {
public:
    static size_t _idGenerator;
    static Physics _nativePhysics;
    
    
};

}
}

#endif /* physics_manager_hpp */
