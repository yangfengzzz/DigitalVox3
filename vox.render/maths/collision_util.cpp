//
//  collision_util.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/25.
//

#include "collision_util.h"
#include "bounding_frustum.h"
#include "bounding_sphere.h"
#include "ray.h"

namespace ozz {
namespace math {
namespace collision_util {
float distancePlaneAndPoint(const Plane &plane, const Float3 &point) {
    return Dot(plane.normal, point) + plane.distance;
}

PlaneIntersectionType intersectsPlaneAndPoint(const Plane &plane, const Float3 &point) {
    const auto distance = collision_util::distancePlaneAndPoint(plane, point);
    if (distance > 0) {
        return PlaneIntersectionType::Front;
    }
    if (distance < 0) {
        return PlaneIntersectionType::Back;
    }
    return PlaneIntersectionType::Intersecting;
}

PlaneIntersectionType intersectsPlaneAndBox(const Plane &plane, const BoundingBox &box) {
    const auto &min = box.min;
    const auto &max = box.max;
    const auto &normal = plane.normal;
    Float3 front;
    Float3 back;
    
    if (normal.x >= 0) {
        front.x = max.x;
        back.x = min.x;
    } else {
        front.x = min.x;
        back.x = max.x;
    }
    if (normal.y >= 0) {
        front.y = max.y;
        back.y = min.y;
    } else {
        front.y = min.y;
        back.y = max.y;
    }
    if (normal.z >= 0) {
        front.z = max.z;
        back.z = min.z;
    } else {
        front.z = min.z;
        back.z = max.z;
    }
    
    if (collision_util::distancePlaneAndPoint(plane, front) < 0) {
        return PlaneIntersectionType::Back;
    }
    
    if (collision_util::distancePlaneAndPoint(plane, back) > 0) {
        return PlaneIntersectionType::Front;
    }
    
    return PlaneIntersectionType::Intersecting;
}

PlaneIntersectionType intersectsPlaneAndSphere(const Plane &plane, const BoundingSphere &sphere) {
    const auto &center = sphere.center;
    const auto &radius = sphere.radius;
    const auto distance = collision_util::distancePlaneAndPoint(plane, center);
    if (distance > radius) {
        return PlaneIntersectionType::Front;
    }
    if (distance < -radius) {
        return PlaneIntersectionType::Back;
    }
    return PlaneIntersectionType::Intersecting;
}

float intersectsRayAndPlane(const Ray &ray, const Plane &plane) {
    const auto &normal = plane.normal;
    
    const auto dir = Dot(normal, ray.direction);
    // Parallel
    if (std::abs(dir) < kNormalizationToleranceSq) {
        return -1;
    }
    
    const auto position = Dot(normal, ray.origin);
    auto distance = (-plane.distance - position) / dir;
    
    if (distance < 0) {
        if (distance < -kNormalizationToleranceSq) {
            return -1;
        }
        
        distance = 0;
    }
    
    return distance;
}

float intersectsRayAndBox(const Ray &ray, const BoundingBox &box) {
    const auto &origin = ray.origin;
    const auto &direction = ray.direction;
    const auto &min = box.min;
    const auto &max = box.max;
    const auto &dirX = direction.x;
    const auto &dirY = direction.y;
    const auto &dirZ = direction.z;
    const auto &oriX = origin.x;
    const auto &oriY = origin.y;
    const auto &oriZ = origin.z;
    float distance = 0;
    float tmax = std::numeric_limits<float>::max();
    
    if (std::abs(dirX) < kNormalizationToleranceSq) {
        if (oriX < min.x || oriX > max.x) {
            return -1;
        }
    } else {
        const float inverse = 1.0 / dirX;
        float t1 = (min.x - oriX) * inverse;
        float t2 = (max.x - oriX) * inverse;
        
        if (t1 > t2) {
            const auto temp = t1;
            t1 = t2;
            t2 = temp;
        }
        
        distance = std::max(t1, distance);
        tmax = std::min(t2, tmax);
        
        if (distance > tmax) {
            return -1;
        }
    }
    
    if (std::abs(dirY) < kNormalizationToleranceSq) {
        if (oriY < min.y || oriY > max.y) {
            return -1;
        }
    } else {
        const float inverse = 1.0 / dirY;
        float t1 = (min.y - oriY) * inverse;
        float t2 = (max.y - oriY) * inverse;
        
        if (t1 > t2) {
            const auto temp = t1;
            t1 = t2;
            t2 = temp;
        }
        
        distance = std::max(t1, distance);
        tmax = std::min(t2, tmax);
        
        if (distance > tmax) {
            return -1;
        }
    }
    
    if (std::abs(dirZ) < kNormalizationToleranceSq) {
        if (oriZ < min.z || oriZ > max.z) {
            return -1;
        }
    } else {
        const float inverse = 1.0 / dirZ;
        float t1 = (min.z - oriZ) * inverse;
        float t2 = (max.z - oriZ) * inverse;
        
        if (t1 > t2) {
            const auto temp = t1;
            t1 = t2;
            t2 = temp;
        }
        
        distance = std::max(t1, distance);
        tmax = std::min(t2, tmax);
        
        if (distance > tmax) {
            return -1;
        }
    }
    
    return distance;
}

float intersectsRayAndSphere(const Ray &ray, const BoundingSphere &sphere) {
    const auto &origin = ray.origin;
    const auto &direction = ray.direction;
    const auto &center = sphere.center;
    const auto &radius = sphere.radius;
    
    Float3 m = origin - center;
    const auto b = Dot(m, direction);
    const auto c = Dot(m, m) - radius * radius;
    
    if (b > 0 && c > 0) {
        return -1;
    }
    
    float discriminant = b * b - c;
    if (discriminant < 0) {
        return -1;
    }
    
    float distance = -b - std::sqrt(discriminant);
    if (distance < 0) {
        distance = 0;
    }
    
    return distance;
}

bool intersectsBoxAndBox(const BoundingBox &boxA, const BoundingBox &boxB) {
    if (boxA.min.x > boxB.max.x || boxB.min.x > boxA.max.x) {
        return false;
    }
    
    if (boxA.min.y > boxB.max.y || boxB.min.y > boxA.max.y) {
        return false;
    }
    
    return !(boxA.min.z > boxB.max.z || boxB.min.z > boxA.max.z);
}

bool intersectsSphereAndSphere(const BoundingSphere &sphereA, const BoundingSphere &sphereB) {
    const auto radiisum = sphereA.radius + sphereB.radius;
    return LengthSqr(sphereA.center - sphereB.center) < radiisum * radiisum;
}

bool intersectsSphereAndBox(const BoundingSphere &sphere, const BoundingBox &box) {
    const auto &center = sphere.center;
    const auto &max = box.max;
    const auto &min = box.min;
    
    Float3 closestPoint = Float3(std::max(min.x, std::min(center.x, max.x)),
                                 std::max(min.y, std::min(center.y, max.y)),
                                 std::max(min.z, std::min(center.z, max.z)));
    
    const auto distance = LengthSqr(center - closestPoint);
    return distance <= sphere.radius * sphere.radius;
}

bool intersectsFrustumAndBox(const BoundingFrustum &frustum, const BoundingBox &box) {
    const auto &min = box.min;
    const auto &max = box.max;
    Float3 back;
    
    for (int i = 0; i < 6; ++i) {
        const auto plane = frustum.getPlane(i);
        const auto &normal = plane.normal;
        
        back.x = normal.x >= 0 ? min.x : max.x;
        back.y = normal.y >= 0 ? min.y : max.y;
        back.z = normal.z >= 0 ? min.z : max.z;
        if (Dot(plane.normal, back) > -plane.distance) {
            return false;
        }
    }
    
    return true;
}

ContainmentType frustumContainsBox(const BoundingFrustum &frustum, const BoundingBox &box) {
    const auto &min = box.min;
    const auto &max = box.max;
    Float3 front;
    Float3 back;
    auto result = ContainmentType::Contains;
    
    for (int i = 0; i < 6; ++i) {
        const auto plane = frustum.getPlane(i);
        const auto &normal = plane.normal;
        
        if (normal.x >= 0) {
            front.x = max.x;
            back.x = min.x;
        } else {
            front.x = min.x;
            back.x = max.x;
        }
        if (normal.y >= 0) {
            front.y = max.y;
            back.y = min.y;
        } else {
            front.y = min.y;
            back.y = max.y;
        }
        if (normal.z >= 0) {
            front.z = max.z;
            back.z = min.z;
        } else {
            front.z = min.z;
            back.z = max.z;
        }
        
        if (collision_util::intersectsPlaneAndPoint(plane, back) == PlaneIntersectionType::Front) {
            return ContainmentType::Disjoint;
        }
        
        if (collision_util::intersectsPlaneAndPoint(plane, front) == PlaneIntersectionType::Front) {
            result = ContainmentType::Intersects;
        }
    }
    
    return result;
}

ContainmentType frustumContainsSphere(const BoundingFrustum &frustum, const BoundingSphere &sphere) {
    auto result = ContainmentType::Contains;
    
    for (int i = 0; i < 6; ++i) {
        const auto plane = frustum.getPlane(i);
        const auto intersectionType = collision_util::intersectsPlaneAndSphere(plane, sphere);
        if (intersectionType == PlaneIntersectionType::Front) {
            return ContainmentType::Disjoint;
        } else if (intersectionType == PlaneIntersectionType::Intersecting) {
            result = ContainmentType::Intersects;
            break;
        }
    }
    
    return result;
}

}
}
}
