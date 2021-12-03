//
//  hit_result.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#ifndef hit_result_hpp
#define hit_result_hpp

#include "maths/vec_float.h"

namespace vox {
class Entity;
namespace physics {

/**
 * Structure used to get information back from a raycast or a sweep.
 */
struct HitResult {
    /** The entity that was hit. */
    Entity* entity = nullptr;
    /** The distance from the ray's origin to the impact point. */
    float distance = 0;
    /** The impact point in world space where the ray hit the collider. */
    math::Float3 point = math::Float3();
    /** The normal of the surface the ray hit. */
    math::Float3 normal = math::Float3();
};

}
}


#endif /* hit_result_hpp */
