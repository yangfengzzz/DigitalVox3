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
void normalize(const Plane& p, Plane& out);

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
    Plane(const Float3& normal = Float3(), float distance = 0)
    :normal(normal), distance(distance) {}
    
    /**
     * Calculate the plane that contains the three specified points.
     * @param point0 - The first point
     * @param point1 - The second point
     * @param point2 - The third point
     */
    static Plane fromPoints(const Float3& point0, const Float3& point1, const Float3& point2) {
        const auto& x0 = point0.x;
        const auto& y0 = point0.y;
        const auto& z0 = point0.z;
        const auto x1 = point1.x - x0;
        const auto y1 = point1.y - y0;
        const auto z1 = point1.z - z0;
        const auto x2 = point2.x - x0;
        const auto y2 = point2.y - y0;
        const auto z2 = point2.z - z0;
        const auto yz = y1 * z2 - z1 * y2;
        const auto xz = z1 * x2 - x1 * z2;
        const auto xy = x1 * y2 - y1 * x2;
        const auto invPyth = 1.0 / std::sqrt(yz * yz + xz * xz + xy * xy);
        
        const auto x = yz * invPyth;
        const auto y = xz * invPyth;
        const auto z = xy * invPyth;
        
        Plane out;
        auto& normal = out.normal;
        normal.x = x;
        normal.y = y;
        normal.z = z;
        
        out.distance = -(x * x0 + y * y0 + z * z0);
        return out;
    }
    
    /**
     * Normalize the normal vector of this plane.
     */
    void normalize() {
        ::ozz::math::normalize(*this, *this);
    }
};

/**
 * Normalize the normal vector of the specified plane.
 * @param p - The specified plane
 * @param out - A normalized version of the specified plane
 */
void normalize(const Plane& p, Plane& out) {
    const auto& normal = p.normal;
    const auto factor = 1.0 / Length(normal);
    
    auto& outNormal = out.normal;
    outNormal.x = normal.x * factor;
    outNormal.y = normal.y * factor;
    outNormal.z = normal.z * factor;
    out.distance = p.distance * factor;
}

}
}
#endif /* plane_hpp */
