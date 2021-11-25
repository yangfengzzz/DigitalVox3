//
//  collision_util.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/25.
//

#ifndef collision_util_hpp
#define collision_util_hpp

#include <cassert>
#include <cmath>
#include <array>
#include "maths/math_constant.h"
#include "platform.h"
#include "vec_float.h"
#include "enums/containment_type.h"
#include "enums/planeIntersection_type.h"

namespace ozz {
namespace math {
struct Plane;
struct BoundingBox;
struct BoundingSphere;
struct BoundingFrustum;
struct Ray;

namespace collision_util {
/**
 * Calculate the distance from a point to a plane.
 * @param plane - The plane
 * @param point - The point
 * @returns The distance from a point to a plane
 */
float distancePlaneAndPoint(const Plane& plane, const Float3& point);

/**
 * Get the intersection type between a plane and a point.
 * @param plane - The plane
 * @param point - The point
 * @returns The intersection type
 */
PlaneIntersectionType intersectsPlaneAndPoint(const Plane& plane, const Float3& point);

/**
 * Get the intersection type between a plane and a box (AABB).
 * @param plane - The plane
 * @param box - The box
 * @returns The intersection type
 */
PlaneIntersectionType intersectsPlaneAndBox(const Plane& plane, const BoundingBox& box);
/**
 * Get the intersection type between a plane and a sphere.
 * @param plane - The plane
 * @param sphere - The sphere
 * @returns The intersection type
 */
PlaneIntersectionType intersectsPlaneAndSphere(const Plane& plane, const BoundingSphere& sphere);

/**
 * Get the intersection type between a ray and a plane.
 * @param ray - The ray
 * @param plane - The plane
 * @returns The distance from ray to plane if intersecting, -1 otherwise
 */
float intersectsRayAndPlane(const Ray& ray, const Plane& plane);

/**
 * Get the intersection type between a ray and a box (AABB).
 * @param ray - The ray
 * @param box - The box
 * @returns The distance from ray to box if intersecting, -1 otherwise
 */
float intersectsRayAndBox(const Ray& ray, const BoundingBox& box);

/**
 * Get the intersection type between a ray and a sphere.
 * @param ray - The ray
 * @param sphere - The sphere
 * @returns The distance from ray to sphere if intersecting, -1 otherwise
 */
float intersectsRayAndSphere(const Ray& ray, const BoundingSphere& sphere);

/**
 * Check whether the boxes intersect.
 * @param boxA - The first box to check
 * @param boxB - The second box to check
 * @returns True if the boxes intersect, false otherwise
 */
bool intersectsBoxAndBox(const BoundingBox& boxA, const BoundingBox& boxB);

/**
 * Check whether the spheres intersect.
 * @param sphereA - The first sphere to check
 * @param sphereB - The second sphere to check
 * @returns True if the spheres intersect, false otherwise
 */
bool intersectsSphereAndSphere(const BoundingSphere& sphereA, const BoundingSphere& sphereB);

/**
 * Check whether the sphere and the box intersect.
 * @param sphere - The sphere to check
 * @param box - The box to check
 * @returns True if the sphere and the box intersect, false otherwise
 */
bool intersectsSphereAndBox(const BoundingSphere& sphere, const BoundingBox& box);

/**
 * Get whether or not a specified bounding box intersects with this frustum (Contains or Intersects).
 * @param frustum - The frustum
 * @param box - The box
 * @returns True if bounding box intersects with this frustum, false otherwise
 */
bool intersectsFrustumAndBox(const BoundingFrustum& frustum, const BoundingBox& box);

/**
 * Get the containment type between a frustum and a box (AABB).
 * @param frustum - The frustum
 * @param box - The box
 * @returns The containment type
 */
ContainmentType frustumContainsBox(const BoundingFrustum& frustum, const BoundingBox& box);

/**
 * Get the containment type between a frustum and a sphere.
 * @param frustum - The frustum
 * @param sphere - The sphere
 * @returns The containment type
 */
ContainmentType frustumContainsSphere(const BoundingFrustum& frustum, const BoundingSphere& sphere);

}
}
}
#endif /* collision_util_hpp */
