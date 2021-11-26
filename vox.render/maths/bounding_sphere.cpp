//
//  bounding_sphere.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/24.
//

#include "bounding_sphere.h"
#include "bounding_box.h"

namespace ozz {
namespace math {
BoundingSphere BoundingSphere::fromBox(const BoundingBox &box) {
    BoundingSphere out;
    auto &center = out.center;
    const auto &min = box.min;
    const auto &max = box.max;
    
    center.x = (min.x + max.x) * 0.5;
    center.y = (min.y + max.y) * 0.5;
    center.z = (min.z + max.z) * 0.5;
    out.radius = Length(center - max);
    return out;
}

}
}
