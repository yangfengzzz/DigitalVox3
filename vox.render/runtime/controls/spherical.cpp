//
//  spherical.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/30.
//

#include "spherical.h"
#include "maths/math_ex.h"

namespace vox {
namespace control {
Spherical::Spherical(float radius, float phi, float theta) :
radius(radius),
phi(phi),
theta(theta) {
}

void Spherical::set(float radius, float phi, float theta) {
    this->radius = radius;
    this->phi = phi;
    this->theta = theta;
}

void Spherical::makeSafe() {
    this->phi = math::Clamp<float>(phi, math::kNormalizationToleranceSq, M_PI - math::kNormalizationToleranceSq);
}

void Spherical::setFromVec3(const math::Float3 &v3) {
    radius = Length(v3);
    if (radius == 0) {
        theta = 0;
        phi = 0;
    } else {
        theta = std::atan2(v3.x, v3.z);
        phi = std::acos(math::Clamp<float>(v3.y / radius, -1, 1));
    }
}

void Spherical::setToVec3(math::Float3 &v3) {
    const auto sinPhiRadius = std::sin(phi) * radius;
    
    v3.x = sinPhiRadius * std::sin(theta);
    v3.y = std::cos(phi) * radius;
    v3.z = sinPhiRadius * std::cos(theta);
}

}
}
