//
//  ray.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/25.
//

#ifndef ray_hpp
#define ray_hpp

#include <cassert>
#include <cmath>
#include <array>
#include "maths/math_constant.h"
#include "platform.h"
#include "vec_float.h"
#include <optional>

namespace ozz {
namespace math {
struct Plane;
struct BoundingSphere;
struct BoundingBox;

/**
 * Represents a ray with an origin and a direction in 3D space.
 */
struct Ray {
    /** The origin of the ray. */
    Float3 origin;
    /** The normalized direction of the ray. */
    Float3 direction;
    
    /**
     * Constructor of Ray.
     * @param origin - The origin vector
     * @param direction - The direction vector
     */
    Ray(std::optional<Float3> origin = std::nullopt, std::optional<Float3> direction = std::nullopt);
    
    /**
     * Check if this ray intersects the specified plane.
     * @param plane - The specified plane
     * @returns The distance from this ray to the specified plane if intersecting, -1 otherwise
     */
    float intersectPlane(const Plane &plane) const;
    
    /**
     * Check if this ray intersects the specified sphere.
     * @param sphere - The specified sphere
     * @returns The distance from this ray to the specified sphere if intersecting, -1 otherwise
     */
    float intersectSphere(const BoundingSphere &sphere) const;
    
    /**
     * Check if this ray intersects the specified box (AABB).
     * @param box - The specified box
     * @returns The distance from this ray to the specified box if intersecting, -1 otherwise
     */
    float intersectBox(const BoundingBox &box) const;
    
    /**
     * The coordinates of the specified distance from the origin in the ray direction.
     * @param distance - The specified distance
     * @return out - The coordinates as an output parameter
     */
    Float3 getPoint(float distance) const;
};

}
}
#endif /* ray_hpp */
