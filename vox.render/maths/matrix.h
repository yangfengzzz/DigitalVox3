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
    
    OZZ_INLINE Matrix(float m11 = 1,
                      float m12 = 0,
                      float m13 = 0,
                      float m14 = 0,
                      float m21 = 0,
                      float m22 = 1,
                      float m23 = 0,
                      float m24 = 0,
                      float m31 = 0,
                      float m32 = 0,
                      float m33 = 1,
                      float m34 = 0,
                      float m41 = 0,
                      float m42 = 0,
                      float m43 = 0,
                      float m44 = 1) {
        auto& e = elements;
        
        e[0] = m11;
        e[1] = m12;
        e[2] = m13;
        e[3] = m14;
        
        e[4] = m21;
        e[5] = m22;
        e[6] = m23;
        e[7] = m24;
        
        e[8] = m31;
        e[9] = m32;
        e[10] = m33;
        e[11] = m34;
        
        e[12] = m41;
        e[13] = m42;
        e[14] = m43;
        e[15] = m44;
    }
    
    /**
     * Calculate a determinant of this matrix.
     * @returns The determinant of this matrix
     */
    OZZ_INLINE float determinant() {
        const auto& e = elements;
        
        const auto& a11 = e[0],
        a12 = e[1],
        a13 = e[2],
        a14 = e[3];
        const auto& a21 = e[4],
        a22 = e[5],
        a23 = e[6],
        a24 = e[7];
        const auto& a31 = e[8],
        a32 = e[9],
        a33 = e[10],
        a34 = e[11];
        const auto& a41 = e[12],
        a42 = e[13],
        a43 = e[14],
        a44 = e[15];
        
        auto b00 = a11 * a22 - a12 * a21;
        auto b01 = a11 * a23 - a13 * a21;
        auto b02 = a11 * a24 - a14 * a21;
        auto b03 = a12 * a23 - a13 * a22;
        auto b04 = a12 * a24 - a14 * a22;
        auto b05 = a13 * a24 - a14 * a23;
        auto b06 = a31 * a42 - a32 * a41;
        auto b07 = a31 * a43 - a33 * a41;
        auto b08 = a31 * a44 - a34 * a41;
        auto b09 = a32 * a43 - a33 * a42;
        auto b10 = a32 * a44 - a34 * a42;
        auto b11 = a33 * a44 - a34 * a43;
        
        // Calculate the determinant
        return b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
    }
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

/**
 * Performs a linear interpolation between two matrices.
 * @param start - The first matrix
 * @param end - The second matrix
 * @param t - The blend amount where 0 returns start and 1 end
 * @param out - The result of linear blending between two matrices
 */
OZZ_INLINE void Lerp(const Matrix& start, const Matrix& end, float t, Matrix& out) {
    const auto& se = start.elements;
    const auto& ee = end.elements;
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
}

/**
 * Calculate a rotation matrix from a quaternion.
 * @param quaternion - The quaternion used to calculate the matrix
 * @reparamturn out - The calculated rotation matrix
 */
OZZ_INLINE void rotationQuaternion(const Quaternion& quaternion, Matrix& out) {
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
}

/**
 * Calculate a matrix rotates around an arbitrary axis.
 * @param axis - The axis
 * @param r - The rotation angle in radians
 * @param out - The matrix after rotate
 */
OZZ_INLINE void rotationAxisAngle(const Float3& axis, float r, Matrix& out) {
    auto& oe = out.elements;
    auto x = axis.x;
    auto y = axis.y;
    auto z = axis.z;
    float len = std::sqrt(x * x + y * y + z * z);
    float s, c, t;
    
    if (std::abs(len) < kNormalizationToleranceSq) {
        return;
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
}

/**
 * Calculate a matrix from a quaternion and a translation.
 * @param quaternion - The quaternion used to calculate the matrix
 * @param translation - The translation used to calculate the matrix
 * @param out - The calculated matrix
 */
OZZ_INLINE void rotationTranslation(const Quaternion& quaternion, const Float3& translation, Matrix& out) {
    rotationQuaternion(quaternion, out);
    
    auto& oe = out.elements;
    oe[12] = translation.x;
    oe[13] = translation.y;
    oe[14] = translation.z;
}

/**
 * Calculate an affine matrix.
 * @param scale - The scale used to calculate matrix
 * @param rotation - The rotation used to calculate matrix
 * @param translation - The translation used to calculate matrix
 * @param out - The calculated matrix
 */
OZZ_INLINE void affineTransformation(const Float3& scale, const Quaternion& rotation, const Float3& translation, Matrix& out) {
    auto& oe = out.elements;
    const auto& x = rotation.x;
    const auto& y = rotation.y;
    const auto& z = rotation.z;
    const auto& w = rotation.w;
    
    auto x2 = x + x;
    auto y2 = y + y;
    auto z2 = z + z;
    
    auto xx = x * x2;
    auto xy = x * y2;
    auto xz = x * z2;
    auto yy = y * y2;
    auto yz = y * z2;
    auto zz = z * z2;
    auto wx = w * x2;
    auto wy = w * y2;
    auto wz = w * z2;
    auto sx = scale.x;
    auto sy = scale.y;
    auto sz = scale.z;
    
    oe[0] = (1 - (yy + zz)) * sx;
    oe[1] = (xy + wz) * sx;
    oe[2] = (xz - wy) * sx;
    oe[3] = 0;
    
    oe[4] = (xy - wz) * sy;
    oe[5] = (1 - (xx + zz)) * sy;
    oe[6] = (yz + wx) * sy;
    oe[7] = 0;
    
    oe[8] = (xz + wy) * sz;
    oe[9] = (yz - wx) * sz;
    oe[10] = (1 - (xx + yy)) * sz;
    oe[11] = 0;
    
    oe[12] = translation.x;
    oe[13] = translation.y;
    oe[14] = translation.z;
    oe[15] = 1;
}

/**
 * Calculate a matrix from scale vector.
 * @param s - The scale vector
 * @param out - The calculated matrix
 */
OZZ_INLINE void scaling(const Float3& s, Matrix& out) {
    auto& oe = out.elements;
    oe[0] = s.x;
    oe[1] = 0;
    oe[2] = 0;
    oe[3] = 0;
    
    oe[4] = 0;
    oe[5] = s.y;
    oe[6] = 0;
    oe[7] = 0;
    
    oe[8] = 0;
    oe[9] = 0;
    oe[10] = s.z;
    oe[11] = 0;
    
    oe[12] = 0;
    oe[13] = 0;
    oe[14] = 0;
    oe[15] = 1;
}

/**
 * Calculate a matrix from translation vector.
 * @param translation - The translation vector
 * @param out - The calculated matrix
 */
OZZ_INLINE void translation(const Float3& translation, Matrix& out) {
    auto& oe = out.elements;
    oe[0] = 1;
    oe[1] = 0;
    oe[2] = 0;
    oe[3] = 0;
    
    oe[4] = 0;
    oe[5] = 1;
    oe[6] = 0;
    oe[7] = 0;
    
    oe[8] = 0;
    oe[9] = 0;
    oe[10] = 1;
    oe[11] = 0;
    
    oe[12] = translation.x;
    oe[13] = translation.y;
    oe[14] = translation.z;
    oe[15] = 1;
}

/**
 * Calculate the inverse of the specified matrix.
 * @param a - The matrix whose inverse is to be calculated
 * @param out - The inverse of the specified matrix
 */
OZZ_INLINE void invert(const Matrix& a, Matrix& out) {
    const auto& ae = a.elements;
    auto& oe = out.elements;
    
    const auto& a11 = ae[0],
    a12 = ae[1],
    a13 = ae[2],
    a14 = ae[3];
    const auto& a21 = ae[4],
    a22 = ae[5],
    a23 = ae[6],
    a24 = ae[7];
    const  auto& a31 = ae[8],
    a32 = ae[9],
    a33 = ae[10],
    a34 = ae[11];
    const  auto& a41 = ae[12],
    a42 = ae[13],
    a43 = ae[14],
    a44 = ae[15];
    
    auto b00 = a11 * a22 - a12 * a21;
    auto b01 = a11 * a23 - a13 * a21;
    auto b02 = a11 * a24 - a14 * a21;
    auto b03 = a12 * a23 - a13 * a22;
    auto b04 = a12 * a24 - a14 * a22;
    auto b05 = a13 * a24 - a14 * a23;
    auto b06 = a31 * a42 - a32 * a41;
    auto b07 = a31 * a43 - a33 * a41;
    auto b08 = a31 * a44 - a34 * a41;
    auto b09 = a32 * a43 - a33 * a42;
    auto b10 = a32 * a44 - a34 * a42;
    auto b11 = a33 * a44 - a34 * a43;
    
    auto det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
    if (!det) {
        return;
    }
    det = 1.0 / det;
    
    oe[0] = (a22 * b11 - a23 * b10 + a24 * b09) * det;
    oe[1] = (a13 * b10 - a12 * b11 - a14 * b09) * det;
    oe[2] = (a42 * b05 - a43 * b04 + a44 * b03) * det;
    oe[3] = (a33 * b04 - a32 * b05 - a34 * b03) * det;
    
    oe[4] = (a23 * b08 - a21 * b11 - a24 * b07) * det;
    oe[5] = (a11 * b11 - a13 * b08 + a14 * b07) * det;
    oe[6] = (a43 * b02 - a41 * b05 - a44 * b01) * det;
    oe[7] = (a31 * b05 - a33 * b02 + a34 * b01) * det;
    
    oe[8] = (a21 * b10 - a22 * b08 + a24 * b06) * det;
    oe[9] = (a12 * b08 - a11 * b10 - a14 * b06) * det;
    oe[10] = (a41 * b04 - a42 * b02 + a44 * b00) * det;
    oe[11] = (a32 * b02 - a31 * b04 - a34 * b00) * det;
    
    oe[12] = (a22 * b07 - a21 * b09 - a23 * b06) * det;
    oe[13] = (a11 * b09 - a12 * b07 + a13 * b06) * det;
    oe[14] = (a42 * b01 - a41 * b03 - a43 * b00) * det;
    oe[15] = (a31 * b03 - a32 * b01 + a33 * b00) * det;
}

/**
 * Calculate a right-handed look-at matrix.
 * @param eye - The position of the viewer's eye
 * @param target - The camera look-at target
 * @param up - The camera's up vector
 * @param out - The calculated look-at matrix
 */
OZZ_INLINE void lookAt(const Float3& eye, const Float3& target, const Float3& up, Matrix& out) {
    auto& oe = out.elements;
    Float3 zAxis = eye - target;
    Normalize(zAxis);
    Float3 xAxis = up - zAxis;
    Normalize(xAxis);
    Float3 yAxis = Cross(zAxis, xAxis);
    
    oe[0] = xAxis.x;
    oe[1] = yAxis.x;
    oe[2] = zAxis.x;
    oe[3] = 0;
    
    oe[4] = xAxis.y;
    oe[5] = yAxis.y;
    oe[6] = zAxis.y;
    oe[7] = 0;
    
    oe[8] = xAxis.z;
    oe[9] = yAxis.z;
    oe[10] = zAxis.z;
    oe[11] = 0;
    
    oe[12] = -Dot(xAxis, eye);
    oe[13] = -Dot(yAxis, eye);
    oe[14] = -Dot(zAxis, eye);
    oe[15] = 1;
}

/**
 * Calculate an orthographic projection matrix.
 * @param left - The left edge of the viewing
 * @param right - The right edge of the viewing
 * @param bottom - The bottom edge of the viewing
 * @param top - The top edge of the viewing
 * @param near - The depth of the near plane
 * @param far - The depth of the far plane
 * @param out - The calculated orthographic projection matrix
 */
OZZ_INLINE void ortho(float left, float right, float bottom, float top, float near, float far, Matrix& out) {
    auto& oe = out.elements;
    auto lr = 1 / (left - right);
    auto bt = 1 / (bottom - top);
    auto nf = 1 / (near - far);
    
    oe[0] = -2 * lr;
    oe[1] = 0;
    oe[2] = 0;
    oe[3] = 0;
    
    oe[4] = 0;
    oe[5] = -2 * bt;
    oe[6] = 0;
    oe[7] = 0;
    
    oe[8] = 0;
    oe[9] = 0;
    oe[10] = 2 * nf;
    oe[11] = 0;
    
    oe[12] = (left + right) * lr;
    oe[13] = (top + bottom) * bt;
    oe[14] = (far + near) * nf;
    oe[15] = 1;
}

/**
 * Calculate a perspective projection matrix.
 * @param fovy - Field of view in the y direction, in radians
 * @param aspect - Aspect ratio, defined as view space width divided by height
 * @param near - The depth of the near plane
 * @param far - The depth of the far plane
 * @param out - The calculated perspective projection matrix
 */
OZZ_INLINE void perspective(float fovy, float aspect, float near, float far,  Matrix& out) {
    auto& oe = out.elements;
    auto f = 1.0 / std::tan(fovy / 2);
    auto nf = 1 / (near - far);
    
    oe[0] = f / aspect;
    oe[1] = 0;
    oe[2] = 0;
    oe[3] = 0;
    
    oe[4] = 0;
    oe[5] = f;
    oe[6] = 0;
    oe[7] = 0;
    
    oe[8] = 0;
    oe[9] = 0;
    oe[10] = (far + near) * nf;
    oe[11] = -1;
    
    oe[12] = 0;
    oe[13] = 0;
    oe[14] = 2 * far * near * nf;
    oe[15] = 0;
}

/**
 * The specified matrix rotates around an arbitrary axis.
 * @param m - The specified matrix
 * @param axis - The axis
 * @param r - The rotation angle in radians
 * @param out - The rotated matrix
 */
OZZ_INLINE void rotateAxisAngle(const Matrix& m, const Float3& axis, float r, Matrix& out) {
    auto x = axis.x;
    auto y = axis.y;
    auto z = axis.z;
    auto len = std::sqrt(x * x + y * y + z * z);
    
    if (std::abs(len) < kNormalizationToleranceSq) {
        return;
    }
    
    const auto& me = m.elements;
    auto& oe = out.elements;
    
    len = 1 / len;
    x *= len;
    y *= len;
    z *= len;
    
    auto s = std::sin(r);
    auto c = std::cos(r);
    auto t = 1 - c;
    
    const auto& a11 = me[0],
    a12 = me[1],
    a13 = me[2],
    a14 = me[3];
    const auto& a21 = me[4],
    a22 = me[5],
    a23 = me[6],
    a24 = me[7];
    const auto& a31 = me[8],
    a32 = me[9],
    a33 = me[10],
    a34 = me[11];
    
    // Construct the elements of the rotation matrix
    auto b11 = x * x * t + c;
    auto b12 = y * x * t + z * s;
    auto b13 = z * x * t - y * s;
    auto b21 = x * y * t - z * s;
    auto b22 = y * y * t + c;
    auto b23 = z * y * t + x * s;
    auto b31 = x * z * t + y * s;
    auto b32 = y * z * t - x * s;
    auto b33 = z * z * t + c;
    
    // Perform rotation-specific matrix multiplication
    oe[0] = a11 * b11 + a21 * b12 + a31 * b13;
    oe[1] = a12 * b11 + a22 * b12 + a32 * b13;
    oe[2] = a13 * b11 + a23 * b12 + a33 * b13;
    oe[3] = a14 * b11 + a24 * b12 + a34 * b13;
    
    oe[4] = a11 * b21 + a21 * b22 + a31 * b23;
    oe[5] = a12 * b21 + a22 * b22 + a32 * b23;
    oe[6] = a13 * b21 + a23 * b22 + a33 * b23;
    oe[7] = a14 * b21 + a24 * b22 + a34 * b23;
    
    oe[8] = a11 * b31 + a21 * b32 + a31 * b33;
    oe[9] = a12 * b31 + a22 * b32 + a32 * b33;
    oe[10] = a13 * b31 + a23 * b32 + a33 * b33;
    oe[11] = a14 * b31 + a24 * b32 + a34 * b33;
    
    if (&m != &out) {
        // If the source and destination differ, copy the unchanged last row
        oe[12] = me[12];
        oe[13] = me[13];
        oe[14] = me[14];
        oe[15] = me[15];
    }
}

/**
 * Scale a matrix by a given vector.
 * @param m - The matrix
 * @param s - The given vector
 * @param out - The scaled matrix
 */
OZZ_INLINE void scale(const Matrix& m, const Float3& s, Matrix& out) {
    const auto& me = m.elements;
    auto& oe = out.elements;
    const auto& x = s.x;
    const auto& y = s.y;
    const auto& z = s.z;
    
    oe[0] = me[0] * x;
    oe[1] = me[1] * x;
    oe[2] = me[2] * x;
    oe[3] = me[3] * x;
    
    oe[4] = me[4] * y;
    oe[5] = me[5] * y;
    oe[6] = me[6] * y;
    oe[7] = me[7] * y;
    
    oe[8] = me[8] * z;
    oe[9] = me[9] * z;
    oe[10] = me[10] * z;
    oe[11] = me[11] * z;
    
    oe[12] = me[12];
    oe[13] = me[13];
    oe[14] = me[14];
    oe[15] = me[15];
}

/**
 * Translate a matrix by a given vector.
 * @param m - The matrix
 * @param v - The given vector
 * @param out - The translated matrix
 */
OZZ_INLINE void translate(const Matrix& m, const Float3& v, Matrix& out) {
    const auto& me = m.elements;
    auto& oe = out.elements;
    const auto& x = v.x;
    const auto& y = v.y;
    const auto& z = v.z;
    
    if (&m == &out) {
        oe[12] = me[0] * x + me[4] * y + me[8] * z + me[12];
        oe[13] = me[1] * x + me[5] * y + me[9] * z + me[13];
        oe[14] = me[2] * x + me[6] * y + me[10] * z + me[14];
        oe[15] = me[3] * x + me[7] * y + me[11] * z + me[15];
    } else {
        const auto& a11 = me[0],
        a12 = me[1],
        a13 = me[2],
        a14 = me[3];
        const auto& a21 = me[4],
        a22 = me[5],
        a23 = me[6],
        a24 = me[7];
        const auto& a31 = me[8],
        a32 = me[9],
        a33 = me[10],
        a34 = me[11];
        
        oe[0] = a11; oe[1] = a12; oe[2] = a13; oe[3] = a14;
        oe[4] = a21; oe[5] = a22; oe[6] = a23; oe[7] = a24;
        oe[8] = a31; oe[9] = a32; oe[10] = a33; oe[11] = a34;
        
        oe[12] = a11 * x + a21 * y + a31 * z + me[12];
        oe[13] = a12 * x + a22 * y + a32 * z + me[13];
        oe[14] = a13 * x + a23 * y + a33 * z + me[14];
        oe[15] = a14 * x + a24 * y + a34 * z + me[15];
    }
}

/**
 * Calculate the transpose of the specified matrix.
 * @param a - The specified matrix
 * @param out - The transpose of the specified matrix
 */
OZZ_INLINE void transpose(const Matrix& a, Matrix& out) {
    const auto& ae = a.elements;
    auto& oe = out.elements;
    
    if (&out == &a) {
        const auto& a12 = ae[1];
        const auto& a13 = ae[2];
        const auto& a14 = ae[3];
        const auto& a23 = ae[6];
        const auto& a24 = ae[7];
        const auto& a34 = ae[11];
        
        oe[1] = ae[4];
        oe[2] = ae[8];
        oe[3] = ae[12];
        
        oe[4] = a12;
        oe[6] = ae[9];
        oe[7] = ae[13];
        
        oe[8] = a13;
        oe[9] = a23;
        oe[11] = ae[14];
        
        oe[12] = a14;
        oe[13] = a24;
        oe[14] = a34;
    } else {
        oe[0] = ae[0];
        oe[1] = ae[4];
        oe[2] = ae[8];
        oe[3] = ae[12];
        
        oe[4] = ae[1];
        oe[5] = ae[5];
        oe[6] = ae[9];
        oe[7] = ae[13];
        
        oe[8] = ae[2];
        oe[9] = ae[6];
        oe[10] = ae[10];
        oe[11] = ae[14];
        
        oe[12] = ae[3];
        oe[13] = ae[7];
        oe[14] = ae[11];
        oe[15] = ae[15];
    }
}


}
}
#endif /* matrix_hpp */
