//
//  plane.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/24.
//

#include "plane.h"

namespace vox {
namespace math {
Plane Plane::fromPoints(const Float3 &point0, const Float3 &point1, const Float3 &point2) {
    const auto &x0 = point0.x;
    const auto &y0 = point0.y;
    const auto &z0 = point0.z;
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
    auto &normal = out.normal;
    normal.x = x;
    normal.y = y;
    normal.z = z;
    
    out.distance = -(x * x0 + y * y0 + z * z0);
    return out;
}

Plane normalize(const Plane &p) {
    const auto &normal = p.normal;
    const auto factor = 1.0 / Length(normal);
    
    return Plane(Float3(normal.x * factor, normal.y * factor, normal.z * factor), p.distance * factor);
}

}
}
