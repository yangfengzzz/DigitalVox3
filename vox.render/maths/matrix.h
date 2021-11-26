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
#include "matrix3x3.h"

namespace ozz {
namespace math {
struct Matrix;

OZZ_INLINE Matrix invert(const Matrix &a);

OZZ_INLINE Matrix rotateAxisAngle(const Matrix &m, const Float3 &axis, float r);

OZZ_INLINE Matrix scale(const Matrix &m, const Float3 &s);

OZZ_INLINE Matrix translate(const Matrix &m, const Float3 &v);

OZZ_INLINE Matrix transpose(const Matrix &a);

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
        auto &e = elements;
        
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
        const auto &e = elements;
        
        const auto &a11 = e[0],
        a12 = e[1],
        a13 = e[2],
        a14 = e[3];
        const auto &a21 = e[4],
        a22 = e[5],
        a23 = e[6],
        a24 = e[7];
        const auto &a31 = e[8],
        a32 = e[9],
        a33 = e[10],
        a34 = e[11];
        const auto &a41 = e[12],
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
    
    /**
     * Decompose this matrix to translation, rotation and scale elements.
     * @param translation - Translation vector as an output parameter
     * @param rotation - Rotation quaternion as an output parameter
     * @param scale - Scale vector as an output parameter
     * @returns True if this matrix can be decomposed, false otherwise
     */
    bool decompose(Float3 &translation, Quaternion &rotation, Float3 &scale) {
        Matrix3x3 rm;
        
        const auto &e = elements;
        auto &rme = rm.elements;
        
        const auto &m11 = e[0];
        const auto &m12 = e[1];
        const auto &m13 = e[2];
        const auto &m14 = e[3];
        const auto &m21 = e[4];
        const auto &m22 = e[5];
        const auto &m23 = e[6];
        const auto &m24 = e[7];
        const auto &m31 = e[8];
        const auto &m32 = e[9];
        const auto &m33 = e[10];
        const auto &m34 = e[11];
        
        translation.x = e[12];
        translation.y = e[13];
        translation.z = e[14];
        
        const auto xs = sgn(m11 * m12 * m13 * m14) < 0 ? -1 : 1;
        const auto ys = sgn(m21 * m22 * m23 * m24) < 0 ? -1 : 1;
        const auto zs = sgn(m31 * m32 * m33 * m34) < 0 ? -1 : 1;
        
        const auto sx = xs * std::sqrt(m11 * m11 + m12 * m12 + m13 * m13);
        const auto sy = ys * std::sqrt(m21 * m21 + m22 * m22 + m23 * m23);
        const auto sz = zs * std::sqrt(m31 * m31 + m32 * m32 + m33 * m33);
        
        scale.x = sx;
        scale.y = sy;
        scale.z = sz;
        
        if (
            std::abs(sx) < kNormalizationToleranceSq ||
            std::abs(sy) < kNormalizationToleranceSq ||
            std::abs(sz) < kNormalizationToleranceSq
            ) {
                rotation.identity();
                return false;
            } else {
                const auto invSX = 1 / sx;
                const auto invSY = 1 / sy;
                const auto invSZ = 1 / sz;
                
                rme[0] = m11 * invSX;
                rme[1] = m12 * invSX;
                rme[2] = m13 * invSX;
                rme[3] = m21 * invSY;
                rme[4] = m22 * invSY;
                rme[5] = m23 * invSY;
                rme[6] = m31 * invSZ;
                rme[7] = m32 * invSZ;
                rme[8] = m33 * invSZ;
                rotation = Quaternion::rotationMatrix3x3(rm);
                return true;
            }
    }
    
    /**
     * Get rotation from this matrix.
     * @return out - Rotation quaternion as an output parameter
     */
    Quaternion getRotation() {
        const auto &e = elements;
        auto trace = e[0] + e[5] + e[10];
        
        if (trace > kNormalizationToleranceSq) {
            auto S = std::sqrt(trace + 1.0) * 2;
            return Quaternion((e[6] - e[9]) / S, (e[8] - e[2]) / S, (e[1] - e[4]) / S, 0.25 * S);
        } else if (e[0] > e[5] && e[0] > e[10]) {
            auto S = std::sqrt(1.0 + e[0] - e[5] - e[10]) * 2;
            return Quaternion(0.25 * S, (e[1] + e[4]) / S, (e[8] + e[2]) / S, (e[6] - e[9]) / S);
        } else if (e[5] > e[10]) {
            auto S = std::sqrt(1.0 + e[5] - e[0] - e[10]) * 2;
            return Quaternion((e[1] + e[4]) / S, 0.25 * S, (e[6] + e[9]) / S, (e[8] - e[2]) / S);
        } else {
            auto S = std::sqrt(1.0 + e[10] - e[0] - e[5]) * 2;
            return Quaternion((e[8] + e[2]) / S, (e[6] + e[9]) / S, 0.25 * S, (e[1] - e[4]) / S);
        }
    }
    
    /**
     * Get scale from this matrix.
     * @return out - Scale vector as an output parameter
     */
    Float3 getScaling() {
        const auto &e = elements;
        const auto &m11 = e[0],
        m12 = e[1],
        m13 = e[2];
        const auto &m21 = e[4],
        m22 = e[5],
        m23 = e[6];
        const auto &m31 = e[8],
        m32 = e[9],
        m33 = e[10];
        
        return Float3(std::sqrt(m11 * m11 + m12 * m12 + m13 * m13),
                      std::sqrt(m21 * m21 + m22 * m22 + m23 * m23),
                      std::sqrt(m31 * m31 + m32 * m32 + m33 * m33));
    }
    
    /**
     * Get translation from this matrix.
     * @return out - Translation vector as an output parameter
     */
    Float3 getTranslation() {
        const auto &e = elements;
        return Float3(e[12], e[13], e[14]);
    }
    
    /**
     * Identity this matrix.
     */
    void identity() {
        auto &e = elements;
        
        e[0] = 1;
        e[1] = 0;
        e[2] = 0;
        e[3] = 0;
        
        e[4] = 0;
        e[5] = 1;
        e[6] = 0;
        e[7] = 0;
        
        e[8] = 0;
        e[9] = 0;
        e[10] = 1;
        e[11] = 0;
        
        e[12] = 0;
        e[13] = 0;
        e[14] = 0;
        e[15] = 1;
    }
    
    /**
     * Invert the matrix.
     */
    void invert() {
        *this = ::ozz::math::invert(*this);
    }
    
    /**
     * This matrix rotates around an arbitrary axis.
     * @param axis - The axis
     * @param r - The rotation angle in radians
     */
    void rotateAxisAngle(const Float3 &axis, float r) {
        *this = ::ozz::math::rotateAxisAngle(*this, axis, r);
    }
    
    /**
     * Scale this matrix by a given vector.
     * @param s - The given vector
     */
    void scale(const Float3 &s) {
        *this = ::ozz::math::scale(*this, s);
    }
    
    /**
     * Translate this matrix by a given vector.
     * @param v - The given vector
     */
    void translate(const Float3 &v) {
        *this = ::ozz::math::translate(*this, v);
    }
    
    /**
     * Calculate the transpose of this matrix.
     */
    void transpose() {
        *this = ::ozz::math::transpose(*this);
    }
};

OZZ_INLINE Matrix operator*(const Matrix &left, const Matrix &right) {
    const auto &le = left.elements;
    const auto &re = right.elements;
    Matrix out;
    auto &oe = out.elements;
    
    const auto &l11 = le[0],
    l12 = le[1],
    l13 = le[2],
    l14 = le[3];
    const auto &l21 = le[4],
    l22 = le[5],
    l23 = le[6],
    l24 = le[7];
    const auto &l31 = le[8],
    l32 = le[9],
    l33 = le[10],
    l34 = le[11];
    const auto &l41 = le[12],
    l42 = le[13],
    l43 = le[14],
    l44 = le[15];
    
    const auto &r11 = re[0],
    r12 = re[1],
    r13 = re[2],
    r14 = re[3];
    const auto &r21 = re[4],
    r22 = re[5],
    r23 = re[6],
    r24 = re[7];
    const auto &r31 = re[8],
    r32 = re[9],
    r33 = re[10],
    r34 = re[11];
    const auto &r41 = re[12],
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

OZZ_INLINE bool operator==(const Matrix &left, const Matrix &right) {
    const auto &le = left.elements;
    const auto &re = right.elements;
    
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
 * @return out - The result of linear blending between two matrices
 */
OZZ_INLINE Matrix Lerp(const Matrix &start, const Matrix &end, float t) {
    const auto &se = start.elements;
    const auto &ee = end.elements;
    const auto inv = 1.0 - t;
    
    return Matrix(se[0] * inv + ee[0] * t,
                  se[1] * inv + ee[1] * t,
                  se[2] * inv + ee[2] * t,
                  se[3] * inv + ee[3] * t,
                  
                  se[4] * inv + ee[4] * t,
                  se[5] * inv + ee[5] * t,
                  se[6] * inv + ee[6] * t,
                  se[7] * inv + ee[7] * t,
                  
                  se[8] * inv + ee[8] * t,
                  se[9] * inv + ee[9] * t,
                  se[10] * inv + ee[10] * t,
                  se[11] * inv + ee[11] * t,
                  
                  se[12] * inv + ee[12] * t,
                  se[13] * inv + ee[13] * t,
                  se[14] * inv + ee[14] * t,
                  se[15] * inv + ee[15] * t);
}

/**
 * Calculate a rotation matrix from a quaternion.
 * @param quaternion - The quaternion used to calculate the matrix
 * @return out - The calculated rotation matrix
 */
OZZ_INLINE Matrix rotationQuaternion(const Quaternion &quaternion) {
    const auto &x = quaternion.x;
    const auto &y = quaternion.y;
    const auto &z = quaternion.z;
    const auto &w = quaternion.w;
    
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
    
    return Matrix(1 - yy - zz,
                  yx + wz,
                  zx - wy,
                  0,
                  
                  yx - wz,
                  1 - xx - zz,
                  zy + wx,
                  0,
                  
                  zx + wy,
                  zy - wx,
                  1 - xx - yy,
                  0,
                  
                  0,
                  0,
                  0,
                  1);
}

/**
 * Calculate a matrix rotates around an arbitrary axis.
 * @param axis - The axis
 * @param r - The rotation angle in radians
 * @return out - The matrix after rotate
 */
OZZ_INLINE Matrix rotationAxisAngle(const Float3 &axis, float r) {
    auto x = axis.x;
    auto y = axis.y;
    auto z = axis.z;
    float len = std::sqrt(x * x + y * y + z * z);
    float s, c, t;
    
    if (std::abs(len) < kNormalizationToleranceSq) {
        return Matrix();
    }
    
    len = 1 / len;
    x *= len;
    y *= len;
    z *= len;
    
    s = std::sin(r);
    c = std::cos(r);
    t = 1 - c;
    
    // Perform rotation-specific matrix multiplication
    return Matrix(x * x * t + c,
                  y * x * t + z * s,
                  z * x * t - y * s,
                  0,
                  
                  x * y * t - z * s,
                  y * y * t + c,
                  z * y * t + x * s,
                  0,
                  
                  x * z * t + y * s,
                  y * z * t - x * s,
                  z * z * t + c,
                  0,
                  
                  0,
                  0,
                  0,
                  1);
}

/**
 * Calculate a matrix from a quaternion and a translation.
 * @param quaternion - The quaternion used to calculate the matrix
 * @param translation - The translation used to calculate the matrix
 * @return out - The calculated matrix
 */
OZZ_INLINE Matrix rotationTranslation(const Quaternion &quaternion, const Float3 &translation) {
    auto out = rotationQuaternion(quaternion);
    auto &oe = out.elements;
    oe[12] = translation.x;
    oe[13] = translation.y;
    oe[14] = translation.z;
    return out;
}

/**
 * Calculate an affine matrix.
 * @param scale - The scale used to calculate matrix
 * @param rotation - The rotation used to calculate matrix
 * @param translation - The translation used to calculate matrix
 * @return out - The calculated matrix
 */
OZZ_INLINE Matrix affineTransformation(const Float3 &scale, const Quaternion &rotation, const Float3 &translation) {
    const auto &x = rotation.x;
    const auto &y = rotation.y;
    const auto &z = rotation.z;
    const auto &w = rotation.w;
    
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
    
    return Matrix((1 - (yy + zz)) * sx,
                  (xy + wz) * sx,
                  (xz - wy) * sx,
                  0,
                  
                  (xy - wz) * sy,
                  (1 - (xx + zz)) * sy,
                  (yz + wx) * sy,
                  0,
                  
                  (xz + wy) * sz,
                  (yz - wx) * sz,
                  (1 - (xx + yy)) * sz,
                  0,
                  
                  translation.x,
                  translation.y,
                  translation.z,
                  1);
}

/**
 * Calculate a matrix from scale vector.
 * @param s - The scale vector
 * @return out - The calculated matrix
 */
OZZ_INLINE Matrix scaling(const Float3 &s) {
    return Matrix(s.x,
                  0,
                  0,
                  0,
                  
                  0,
                  s.y,
                  0,
                  0,
                  
                  0,
                  0,
                  s.z,
                  0,
                  
                  0,
                  0,
                  0,
                  1);
}

/**
 * Calculate a matrix from translation vector.
 * @param translation - The translation vector
 * @return out - The calculated matrix
 */
OZZ_INLINE Matrix translation(const Float3 &translation) {
    return Matrix(1,
                  0,
                  0,
                  0,
                  
                  0,
                  1,
                  0,
                  0,
                  
                  0,
                  0,
                  1,
                  0,
                  
                  translation.x,
                  translation.y,
                  translation.z,
                  1);
}

/**
 * Calculate the inverse of the specified matrix.
 * @param a - The matrix whose inverse is to be calculated
 * @return out - The inverse of the specified matrix
 */
OZZ_INLINE Matrix invert(const Matrix &a) {
    const auto &ae = a.elements;
    
    const auto &a11 = ae[0],
    a12 = ae[1],
    a13 = ae[2],
    a14 = ae[3];
    const auto &a21 = ae[4],
    a22 = ae[5],
    a23 = ae[6],
    a24 = ae[7];
    const auto &a31 = ae[8],
    a32 = ae[9],
    a33 = ae[10],
    a34 = ae[11];
    const auto &a41 = ae[12],
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
        return Matrix();
    }
    det = 1.0 / det;
    
    return Matrix((a22 * b11 - a23 * b10 + a24 * b09) * det,
                  (a13 * b10 - a12 * b11 - a14 * b09) * det,
                  (a42 * b05 - a43 * b04 + a44 * b03) * det,
                  (a33 * b04 - a32 * b05 - a34 * b03) * det,
                  
                  (a23 * b08 - a21 * b11 - a24 * b07) * det,
                  (a11 * b11 - a13 * b08 + a14 * b07) * det,
                  (a43 * b02 - a41 * b05 - a44 * b01) * det,
                  (a31 * b05 - a33 * b02 + a34 * b01) * det,
                  
                  (a21 * b10 - a22 * b08 + a24 * b06) * det,
                  (a12 * b08 - a11 * b10 - a14 * b06) * det,
                  (a41 * b04 - a42 * b02 + a44 * b00) * det,
                  (a32 * b02 - a31 * b04 - a34 * b00) * det,
                  
                  (a22 * b07 - a21 * b09 - a23 * b06) * det,
                  (a11 * b09 - a12 * b07 + a13 * b06) * det,
                  (a42 * b01 - a41 * b03 - a43 * b00) * det,
                  (a31 * b03 - a32 * b01 + a33 * b00) * det);
}

/**
 * Calculate a right-handed look-at matrix.
 * @param eye - The position of the viewer's eye
 * @param target - The camera look-at target
 * @param up - The camera's up vector
 * @return out - The calculated look-at matrix
 */
OZZ_INLINE Matrix lookAt(const Float3 &eye, const Float3 &target, const Float3 &up) {
    Float3 zAxis = eye - target;
    Normalize(zAxis);
    Float3 xAxis = up - zAxis;
    Normalize(xAxis);
    Float3 yAxis = Cross(zAxis, xAxis);
    
    return Matrix(xAxis.x,
                  yAxis.x,
                  zAxis.x,
                  0,
                  
                  xAxis.y,
                  yAxis.y,
                  zAxis.y,
                  0,
                  
                  xAxis.z,
                  yAxis.z,
                  zAxis.z,
                  0,
                  
                  -Dot(xAxis, eye),
                  -Dot(yAxis, eye),
                  -Dot(zAxis, eye),
                  1);
}

/**
 * Calculate an orthographic projection matrix.
 * @param left - The left edge of the viewing
 * @param right - The right edge of the viewing
 * @param bottom - The bottom edge of the viewing
 * @param top - The top edge of the viewing
 * @param near - The depth of the near plane
 * @param far - The depth of the far plane
 * @return out - The calculated orthographic projection matrix
 */
OZZ_INLINE Matrix ortho(float left, float right, float bottom, float top, float near, float far) {
    auto lr = 1 / (left - right);
    auto bt = 1 / (bottom - top);
    auto nf = 1 / (near - far);
    
    return Matrix(-2 * lr,
                  0,
                  0,
                  0,
                  
                  0,
                  -2 * bt,
                  0,
                  0,
                  
                  0,
                  0,
                  2 * nf,
                  0,
                  
                  (left + right) * lr,
                  (top + bottom) * bt,
                  (far + near) * nf,
                  1);
}

/**
 * Calculate a perspective projection matrix.
 * @param fovy - Field of view in the y direction, in radians
 * @param aspect - Aspect ratio, defined as view space width divided by height
 * @param near - The depth of the near plane
 * @param far - The depth of the far plane
 * @return out - The calculated perspective projection matrix
 */
OZZ_INLINE Matrix perspective(float fovy, float aspect, float near, float far) {
    auto f = 1.0 / std::tan(fovy / 2);
    auto nf = 1 / (near - far);
    
    return Matrix(f / aspect,
                  0,
                  0,
                  0,
                  
                  0,
                  f,
                  0,
                  0,
                  
                  0,
                  0,
                  (far + near) * nf,
                  -1,
                  
                  0,
                  0,
                  2 * far * near * nf,
                  0);
}

/**
 * The specified matrix rotates around an arbitrary axis.
 * @param m - The specified matrix
 * @param axis - The axis
 * @param r - The rotation angle in radians
 * @return out - The rotated matrix
 */
OZZ_INLINE Matrix rotateAxisAngle(const Matrix &m, const Float3 &axis, float r) {
    auto x = axis.x;
    auto y = axis.y;
    auto z = axis.z;
    auto len = std::sqrt(x * x + y * y + z * z);
    
    if (std::abs(len) < kNormalizationToleranceSq) {
        return Matrix();
    }
    
    const auto &me = m.elements;
    Matrix out = m;
    auto &oe = out.elements;
    
    len = 1 / len;
    x *= len;
    y *= len;
    z *= len;
    
    auto s = std::sin(r);
    auto c = std::cos(r);
    auto t = 1 - c;
    
    const auto &a11 = me[0],
    a12 = me[1],
    a13 = me[2],
    a14 = me[3];
    const auto &a21 = me[4],
    a22 = me[5],
    a23 = me[6],
    a24 = me[7];
    const auto &a31 = me[8],
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
    return out;
}

/**
 * Scale a matrix by a given vector.
 * @param m - The matrix
 * @param s - The given vector
 * @return out - The scaled matrix
 */
OZZ_INLINE Matrix scale(const Matrix &m, const Float3 &s) {
    const auto &me = m.elements;
    const auto &x = s.x;
    const auto &y = s.y;
    const auto &z = s.z;
    
    return Matrix(me[0] * x,
                  me[1] * x,
                  me[2] * x,
                  me[3] * x,
                  
                  me[4] * y,
                  me[5] * y,
                  me[6] * y,
                  me[7] * y,
                  
                  me[8] * z,
                  me[9] * z,
                  me[10] * z,
                  me[11] * z,
                  
                  me[12],
                  me[13],
                  me[14],
                  me[15]);
}

/**
 * Translate a matrix by a given vector.
 * @param m - The matrix
 * @param v - The given vector
 * @return out - The translated matrix
 */
OZZ_INLINE Matrix translate(const Matrix &m, const Float3 &v) {
    const auto &me = m.elements;
    Matrix out = m;
    auto &oe = out.elements;
    const auto &x = v.x;
    const auto &y = v.y;
    const auto &z = v.z;
    
    const auto &a11 = me[0],
    a12 = me[1],
    a13 = me[2],
    a14 = me[3];
    const auto &a21 = me[4],
    a22 = me[5],
    a23 = me[6],
    a24 = me[7];
    const auto &a31 = me[8],
    a32 = me[9],
    a33 = me[10],
    a34 = me[11];
    
    oe[0] = a11;
    oe[1] = a12;
    oe[2] = a13;
    oe[3] = a14;
    oe[4] = a21;
    oe[5] = a22;
    oe[6] = a23;
    oe[7] = a24;
    oe[8] = a31;
    oe[9] = a32;
    oe[10] = a33;
    oe[11] = a34;
    
    oe[12] = a11 * x + a21 * y + a31 * z + me[12];
    oe[13] = a12 * x + a22 * y + a32 * z + me[13];
    oe[14] = a13 * x + a23 * y + a33 * z + me[14];
    oe[15] = a14 * x + a24 * y + a34 * z + me[15];
    return out;
}

/**
 * Calculate the transpose of the specified matrix.
 * @param a - The specified matrix
 * @return out - The transpose of the specified matrix
 */
OZZ_INLINE Matrix transpose(const Matrix &a) {
    const auto &ae = a.elements;
    Matrix out = a;
    auto &oe = out.elements;
    
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
    return out;
}

}
}
#endif /* matrix_hpp */
