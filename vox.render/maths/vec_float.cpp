//
//  vec_float.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/24.
//

#include "vec_float.h"
#include "matrix.h"
#include "quaternion.h"

namespace vox {
namespace math {
void transformNormal(const Float3& v, const Matrix& m, Float3& out) {
    const auto& x = v.x;
    const auto& y = v.y;
    const auto& z = v.z;
    const auto& e = m.elements;
    
    out.x = x * e[0] + y * e[4] + z * e[8];
    out.y = x * e[1] + y * e[5] + z * e[9];
    out.z = x * e[2] + y * e[6] + z * e[10];
}

void transformToVec(const Float3& v, const Matrix& m, Float3& out) {
    const auto& x = v.x;
    const auto& y = v.y;
    const auto& z = v.z;
    const auto& e = m.elements;
    
    out.x = x * e[0] + y * e[4] + z * e[8] + e[12];
    out.y = x * e[1] + y * e[5] + z * e[9] + e[13];
    out.z = x * e[2] + y * e[6] + z * e[10] + e[14];
}

void transformToVec(const Float3& v, const Matrix& m, Float4& out) {
    const auto& x = v.x;
    const auto& y = v.y;
    const auto& z = v.z;
    const auto& e = m.elements;
    
    out.x = x * e[0] + y * e[4] + z * e[8] + e[12];
    out.y = x * e[1] + y * e[5] + z * e[9] + e[13];
    out.z = x * e[2] + y * e[6] + z * e[10] + e[14];
    out.w = x * e[3] + y * e[7] + z * e[11] + e[15];
}

void transformCoordinate(const Float3& v, const Matrix& m, Float3& out) {
    const auto& x = v.x;
    const auto& y = v.y;
    const auto& z = v.z;
    const auto& e = m.elements;
    auto w = x * e[3] + y * e[7] + z * e[11] + e[15];
    w = 1.0 / w;
    
    out.x = (x * e[0] + y * e[4] + z * e[8] + e[12]) * w;
    out.y = (x * e[1] + y * e[5] + z * e[9] + e[13]) * w;
    out.z = (x * e[2] + y * e[6] + z * e[10] + e[14]) * w;
}

void transformByQuat(const Float3& v, const Quaternion& quaternion, Float3& out) {
    const auto& x = v.x;
    const auto& y = v.y;
    const auto& z = v.z;
    
    const auto& qx = quaternion.x;
    const auto& qy = quaternion.y;
    const auto& qz = quaternion.z;
    const auto& qw = quaternion.w;
    
    // calculate quat * vec
    const auto ix = qw * x + qy * z - qz * y;
    const auto iy = qw * y + qz * x - qx * z;
    const auto iz = qw * z + qx * y - qy * x;
    const auto iw = -qx * x - qy * y - qz * z;
    
    // calculate result * inverse quat
    out.x = ix * qw - iw * qx - iy * qz + iz * qy;
    out.y = iy * qw - iw * qy - iz * qx + ix * qz;
    out.z = iz * qw - iw * qz - ix * qy + iy * qx;
}

void transform(const Float4& v, const Matrix& m, Float4& out) {
    const auto& x = v.x;
    const auto& y = v.y;
    const auto& z = v.z;
    const auto& w = v.w;
    const auto& e = m.elements;
    out.x = x * e[0] + y * e[4] + z * e[8] + w * e[12];
    out.y = x * e[1] + y * e[5] + z * e[9] + w * e[13];
    out.z = x * e[2] + y * e[6] + z * e[10] + w * e[14];
    out.w = x * e[3] + y * e[7] + z * e[11] + w * e[15];
}

void transformByQuat(const Float4& v, const Quaternion& q, Float4& out) {
    const auto& x = v.x;
    const auto& y = v.y;
    const auto& z = v.z;
    const auto& w = v.w;
    const auto& qx = q.x;
    const auto& qy = q.y;
    const auto& qz = q.z;
    const auto& qw = q.w;
    
    // calculate quat * vec
    const auto ix = qw * x + qy * z - qz * y;
    const auto iy = qw * y + qz * x - qx * z;
    const auto iz = qw * z + qx * y - qy * x;
    const auto iw = -qx * x - qy * y - qz * z;
    
    // calculate result * inverse quat
    out.x = ix * qw - iw * qx - iy * qz + iz * qy;
    out.y = iy * qw - iw * qy - iz * qx + ix * qz;
    out.z = iz * qw - iw * qz - ix * qy + iy * qx;
    out.w = w;
}

}
}
