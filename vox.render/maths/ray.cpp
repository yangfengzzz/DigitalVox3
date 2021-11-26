//
//  ray.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/25.
//

#include "ray.h"
#include "collision_util.h"

namespace ozz {
namespace math {
Ray::Ray(std::optional<Float3> origin, std::optional<Float3> direction) {
    if (origin) {
        this->origin = origin.value();
    }
    
    if (direction) {
        this->direction = direction.value();
    }
}

float Ray::intersectPlane(const Plane &plane) {
    return collision_util::intersectsRayAndPlane(*this, plane);
}

float Ray::intersectSphere(const BoundingSphere &sphere) {
    return collision_util::intersectsRayAndSphere(*this, sphere);
}

float Ray::intersectBox(const BoundingBox &box) {
    return collision_util::intersectsRayAndBox(*this, box);
}

Float3 Ray::getPoint(float distance) {
    auto out = direction * distance;
    out = out + origin;
    return out;
}

}
}
