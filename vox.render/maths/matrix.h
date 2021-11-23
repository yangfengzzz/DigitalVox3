//
//  matrix.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/23.
//

#ifndef matrix_h
#define matrix_h

#include <cassert>
#include <cmath>
#include <array>
#include "maths/math_constant.h"
#include "platform.h"
#include "quaternion.h"

namespace ozz {
namespace math {
// Represents a 4x4 mathematical matrix.
struct Matrix {
    std::array<float, 16> elements;
};

OZZ_INLINE Matrix operator*(const Matrix& left, const Matrix& right) {
    const auto& le = left.elements;
    const auto& re = right.elements;
    Matrix out;
    auto& oe = out.elements;
    
    const auto& l11 = le[0],
    l12 = le[1],
    l13 = le[2],
    l14 = le[3];
    const auto& l21 = le[4],
    l22 = le[5],
    l23 = le[6],
    l24 = le[7];
    const auto& l31 = le[8],
    l32 = le[9],
    l33 = le[10],
    l34 = le[11];
    const auto& l41 = le[12],
    l42 = le[13],
    l43 = le[14],
    l44 = le[15];
    
    const auto& r11 = re[0],
    r12 = re[1],
    r13 = re[2],
    r14 = re[3];
    const auto& r21 = re[4],
    r22 = re[5],
    r23 = re[6],
    r24 = re[7];
    const auto& r31 = re[8],
    r32 = re[9],
    r33 = re[10],
    r34 = re[11];
    const auto& r41 = re[12],
    r42 = re[13],
    r43 = re[14],
    r44 = re[15];
    
    oe[0] = l11 * r11 + l21 * r12 + l31 * r13 + l41 * r14;
    oe[1] = l12 * r11 + l22 * r12 + l32 * r13 + l42 * r14;
    oe[2] = l13 * r11 + l23 * r12 + l33 * r13 + l43 * r14;
    oe[3] = l14 * r11 + l24 * r12 + l34 * r13 + l44 * r14;
    
    oe[4] = l11 * r21 + l21 * r22 + l31 * r23 + l41 * r24;
    oe[5] = l12 * r21 + l22 * r22 + l32 * r23 + l42 * r24;
    oe[6] = l13 * r21 + l23 * r22 + l33 * r23 + l43 * r24;
    oe[7] = l14 * r21 + l24 * r22 + l34 * r23 + l44 * r24;
    
    oe[8] = l11 * r31 + l21 * r32 + l31 * r33 + l41 * r34;
    oe[9] = l12 * r31 + l22 * r32 + l32 * r33 + l42 * r34;
    oe[10] = l13 * r31 + l23 * r32 + l33 * r33 + l43 * r34;
    oe[11] = l14 * r31 + l24 * r32 + l34 * r33 + l44 * r34;
    
    oe[12] = l11 * r41 + l21 * r42 + l31 * r43 + l41 * r44;
    oe[13] = l12 * r41 + l22 * r42 + l32 * r43 + l42 * r44;
    oe[14] = l13 * r41 + l23 * r42 + l33 * r43 + l43 * r44;
    oe[15] = l14 * r41 + l24 * r42 + l34 * r43 + l44 * r44;
    return out;
}

OZZ_INLINE bool operator==(const Matrix& left, const Matrix& right) {
    const auto& le = left.elements;
    const auto& re = right.elements;
    
    return
    (le[0] == re[0]) &&
    (le[1] == re[1]) &&
    (le[2] == re[2]) &&
    (le[3] == re[3]) &&
    (le[4] == re[4]) &&
    (le[5] == re[5]) &&
    (le[6] == re[6]) &&
    (le[7] == re[7]) &&
    (le[8] == re[8]) &&
    (le[9] == re[9]) &&
    (le[10] == re[10]) &&
    (le[11] == re[11]) &&
    (le[12] == re[12]) &&
    (le[13] == re[13]) &&
    (le[14] == re[14]) &&
    (le[15] == re[15]);
}

OZZ_INLINE Matrix Lerp(const Matrix& start, const Matrix& end, float t) {
    const auto& se = start.elements;
    const auto& ee = end.elements;
    Matrix out;
    auto& oe = out.elements;
    const auto inv = 1.0 - t;
    
    oe[0] = se[0] * inv + ee[0] * t;
    oe[1] = se[1] * inv + ee[1] * t;
    oe[2] = se[2] * inv + ee[2] * t;
    oe[3] = se[3] * inv + ee[3] * t;
    
    oe[4] = se[4] * inv + ee[4] * t;
    oe[5] = se[5] * inv + ee[5] * t;
    oe[6] = se[6] * inv + ee[6] * t;
    oe[7] = se[7] * inv + ee[7] * t;
    
    oe[8] = se[8] * inv + ee[8] * t;
    oe[9] = se[9] * inv + ee[9] * t;
    oe[10] = se[10] * inv + ee[10] * t;
    oe[11] = se[11] * inv + ee[11] * t;
    
    oe[12] = se[12] * inv + ee[12] * t;
    oe[13] = se[13] * inv + ee[13] * t;
    oe[14] = se[14] * inv + ee[14] * t;
    oe[15] = se[15] * inv + ee[15] * t;
    return out;
}

OZZ_INLINE Matrix rotationQuaternion(const Quaternion& quaternion) {
    Matrix out;
    auto& oe = out.elements;
    const auto& x = quaternion.x;
    const auto& y = quaternion.y;
    const auto& z = quaternion.z;
    const auto& w = quaternion.w;
    
    auto x2 = x + x;
    auto y2 = y + y;
    auto z2 = z + z;
    
    auto xx = x * x2;
    auto yx = y * x2;
    auto yy = y * y2;
    auto zx = z * x2;
    auto zy = z * y2;
    auto zz = z * z2;
    auto wx = w * x2;
    auto wy = w * y2;
    auto wz = w * z2;
    
    oe[0] = 1 - yy - zz;
    oe[1] = yx + wz;
    oe[2] = zx - wy;
    oe[3] = 0;
    
    oe[4] = yx - wz;
    oe[5] = 1 - xx - zz;
    oe[6] = zy + wx;
    oe[7] = 0;
    
    oe[8] = zx + wy;
    oe[9] = zy - wx;
    oe[10] = 1 - xx - yy;
    oe[11] = 0;
    
    oe[12] = 0;
    oe[13] = 0;
    oe[14] = 0;
    oe[15] = 1;
    return out;
}

OZZ_INLINE Matrix rotationAxisAngle(const Float3& axis, float r) {
    Matrix out;
    auto& oe = out.elements;
    auto x = axis.x;
    auto y = axis.y;
    auto z = axis.z;
    float len = std::sqrt(x * x + y * y + z * z);
    float s, c, t;
    
    if (std::abs(len) < kNormalizationToleranceSq) {
        return out;
    }
    
    len = 1 / len;
    x *= len;
    y *= len;
    z *= len;
    
    s = std::sin(r);
    c = std::cos(r);
    t = 1 - c;
    
    // Perform rotation-specific matrix multiplication
    oe[0] = x * x * t + c;
    oe[1] = y * x * t + z * s;
    oe[2] = z * x * t - y * s;
    oe[3] = 0;
    
    oe[4] = x * y * t - z * s;
    oe[5] = y * y * t + c;
    oe[6] = z * y * t + x * s;
    oe[7] = 0;
    
    oe[8] = x * z * t + y * s;
    oe[9] = y * z * t - x * s;
    oe[10] = z * z * t + c;
    oe[11] = 0;
    
    oe[12] = 0;
    oe[13] = 0;
    oe[14] = 0;
    oe[15] = 1;
    return out;
}

}
}
#endif /* matrix_hpp */
