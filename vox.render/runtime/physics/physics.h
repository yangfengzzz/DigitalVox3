//
//  physics.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#ifndef physics_hpp
#define physics_hpp

#include "maths/vec_float.h"
#include <PxPhysicsAPI.h>

namespace vox {
namespace physics {
using namespace physx;

class Physics {
public:
    Physics();
    
private:
    PxPhysics* _physics;
    PxDefaultAllocator gAllocator;
    PxDefaultErrorCallback gErrorCallback;
};

}
}

#endif /* physics_hpp */
