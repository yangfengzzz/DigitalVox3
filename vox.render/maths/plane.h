//
//  plane.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/24.
//

#ifndef plane_hpp
#define plane_hpp

#include <cassert>
#include <cmath>
#include <array>
#include "maths/math_constant.h"
#include "platform.h"
#include "vec_float.h"

namespace ozz {
namespace math {
struct Plane;

/**
 * Normalize the normal vector of the specified plane.
 * @param p - The specified plane
 * @return out - A normalized version of the specified plane
 */
Plane normalize(const Plane &p);

struct Plane {
    /** The normal of the plane. */
    Float3 normal;
    /** The distance of the plane along its normal to the origin. */
    float distance = 0;
    
    /**
     * Constructor of Plane.
     * @param normal - The normal vector
     * @param distance - The distance of the plane along its normal to the origin
     */
    Plane(const Float3 &normal = Float3(), float distance = 0)
    : normal(normal), distance(distance) {
    }
    
    /**
     * Calculate the plane that contains the three specified points.
     * @param point0 - The first point
     * @param point1 - The second point
     * @param point2 - The third point
     */
    static Plane fromPoints(const Float3 &point0, const Float3 &point1, const Float3 &point2);
    
    /**
     * Normalize the normal vector of this plane.
     */
    void normalize() {
        *this = ::ozz::math::normalize(*this);
    }
};

}
}
#endif /* plane_hpp */
