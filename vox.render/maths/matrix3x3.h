//
//  matrix3x3.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/24.
//

#ifndef matrix3x3_h
#define matrix3x3_h

#include <cassert>
#include <cmath>
#include <array>
#include "maths/math_constant.h"
#include "platform.h"
#include "quaternion.h"

namespace ozz {
namespace math {
struct Matrix;
struct Matrix3x3;
OZZ_INLINE void invert(const Matrix3x3& a, Matrix3x3& out);
OZZ_INLINE void rotate(const Matrix3x3& a, float r, Matrix3x3& out);
OZZ_INLINE void scale(const Matrix3x3& m, const Float2& s, Matrix3x3& out);
OZZ_INLINE void translate(const Matrix3x3& m, const Float2& translation, Matrix3x3& out);
OZZ_INLINE void transpose(const Matrix3x3& a, Matrix3x3& out);

// Represents a 3x3 mathematical matrix.
struct Matrix3x3 {
    std::array<float, 9> elements;
    
    /**
     * Constructor of 3*3 matrix.
     * @param m11 - Default 1 column 1, row 1
     * @param m12 - Default 0 column 1, row 2
     * @param m13 - Default 0 column 1, row 3
     * @param m21 - Default 0 column 2, row 1
     * @param m22 - Default 1 column 2, row 2
     * @param m23 - Default 0 column 2, row 3
     * @param m31 - Default 0 column 3, row 1
     * @param m32 - Default 0 column 3, row 2
     * @param m33 - Default 1 column 3, row 3
     */
    OZZ_INLINE Matrix3x3(float m11 = 1,
                         float m12 = 0,
                         float m13 = 0,
                         float m21 = 0,
                         float m22 = 1,
                         float m23 = 0,
                         float m31 = 0,
                         float m32 = 0,
                         float m33 = 1) {
        auto& e = elements;
        
        e[0] = m11;
        e[1] = m12;
        e[2] = m13;
        
        e[3] = m21;
        e[4] = m22;
        e[5] = m23;
        
        e[6] = m31;
        e[7] = m32;
        e[8] = m33;
    }
    
    /**
     * Calculate a determinant of this matrix.
     * @returns The determinant of this matrix
     */
    OZZ_INLINE float determinant() {
        auto& e = elements;
        
        const auto& a11 = e[0],
        a12 = e[1],
        a13 = e[2];
        const auto& a21 = e[3],
        a22 = e[4],
        a23 = e[5];
        const auto& a31 = e[6],
        a32 = e[7],
        a33 = e[8];
        
        const auto b12 = a33 * a22 - a23 * a32;
        const auto b22 = -a33 * a21 + a23 * a31;
        const auto b32 = a32 * a21 - a22 * a31;
        
        return a11 * b12 + a12 * b22 + a13 * b32;
    }
    
    /**
     * Identity this matrix.
     */
    OZZ_INLINE void identity() {
        auto& e = elements;
        
        e[0] = 1;
        e[1] = 0;
        e[2] = 0;
        
        e[3] = 0;
        e[4] = 1;
        e[5] = 0;
        
        e[6] = 0;
        e[7] = 0;
        e[8] = 1;
    }
    
    /**
     * Invert the matrix.
     */
    void invert() {
        ::ozz::math::invert(*this, *this);
    }
    
    /**
     * This matrix rotates around an angle.
     * @param r - The rotation angle in radians
     */
    void rotate(float r) {
        ::ozz::math::rotate(*this, r, *this);
    }
    
    /**
     * Scale this matrix by a given vector.
     * @param s - The given vector
     */
    void scale(const Float2& s) {
        ::ozz::math::scale(*this, s, *this);
    }
    
    /**
     * Translate this matrix by a given vector.
     * @param translation - The given vector
     */
    void translate(const Float2& translation) {
        ::ozz::math::translate(*this, translation, *this);
    }
    
    /**
     * Calculate the transpose of this matrix.
     */
    void transpose() {
        ::ozz::math::transpose(*this, *this);
    }
};

OZZ_INLINE Matrix3x3 operator+(const Matrix3x3& left, const Matrix3x3& right) {
    const auto& le = left.elements;
    const auto& re = right.elements;
    Matrix3x3 out;
    auto& oe = out.elements;
    
    oe[0] = le[0] + re[0];
    oe[1] = le[1] + re[1];
    oe[2] = le[2] + re[2];
    
    oe[3] = le[3] + re[3];
    oe[4] = le[4] + re[4];
    oe[5] = le[5] + re[5];
    
    oe[6] = le[6] + re[6];
    oe[7] = le[7] + re[7];
    oe[8] = le[8] + re[8];
    return out;
}

OZZ_INLINE Matrix3x3 operator-(const Matrix3x3& left, const Matrix3x3& right) {
    const auto& le = left.elements;
    const auto& re = right.elements;
    Matrix3x3 out;
    auto& oe = out.elements;
    
    oe[0] = le[0] - re[0];
    oe[1] = le[1] - re[1];
    oe[2] = le[2] - re[2];
    
    oe[3] = le[3] - re[3];
    oe[4] = le[4] - re[4];
    oe[5] = le[5] - re[5];
    
    oe[6] = le[6] - re[6];
    oe[7] = le[7] - re[7];
    oe[8] = le[8] - re[8];
    return out;
}

OZZ_INLINE Matrix3x3 operator*(const Matrix3x3& left, const Matrix3x3& right) {
    const auto& le = left.elements;
    const auto& re = right.elements;
    Matrix3x3 out;
    auto& oe = out.elements;
    
    const auto& l11 = le[0],
    l12 = le[1],
    l13 = le[2];
    const auto& l21 = le[3],
    l22 = le[4],
    l23 = le[5];
    const auto& l31 = le[6],
    l32 = le[7],
    l33 = le[8];
    
    const auto& r11 = re[0],
    r12 = re[1],
    r13 = re[2];
    const auto& r21 = re[3],
    r22 = re[4],
    r23 = re[5];
    const auto& r31 = re[6],
    r32 = re[7],
    r33 = re[8];
    
    oe[0] = l11 * r11 + l21 * r12 + l31 * r13;
    oe[1] = l12 * r11 + l22 * r12 + l32 * r13;
    oe[2] = l13 * r11 + l23 * r12 + l33 * r13;
    
    oe[3] = l11 * r21 + l21 * r22 + l31 * r23;
    oe[4] = l12 * r21 + l22 * r22 + l32 * r23;
    oe[5] = l13 * r21 + l23 * r22 + l33 * r23;
    
    oe[6] = l11 * r31 + l21 * r32 + l31 * r33;
    oe[7] = l12 * r31 + l22 * r32 + l32 * r33;
    oe[8] = l13 * r31 + l23 * r32 + l33 * r33;
    
    return out;
}

OZZ_INLINE bool operator==(const Matrix3x3& left, const Matrix3x3& right) {
    const auto& le = left.elements;
    const auto& re = right.elements;
    
    return (
            (le[0] == re[0]) &&
            (le[1] == re[1]) &&
            (le[2] == re[2]) &&
            (le[3] == re[3]) &&
            (le[4] == re[4]) &&
            (le[5] == re[5]) &&
            (le[6] == re[6]) &&
            (le[7] == re[7]) &&
            (le[8] == re[8])
            );
}

/**
 * Performs a linear interpolation between two matrices.
 * @param start - The first matrix
 * @param end - The second matrix
 * @param t - The blend amount where 0 returns start and 1 end
 * @param out - The result of linear blending between two matrices
 */
OZZ_INLINE void lerp(const Matrix3x3& start, const Matrix3x3& end, float t, Matrix3x3& out) {
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
}

/**
 * Calculate a rotation matrix from a quaternion.
 * @param quaternion - The quaternion used to calculate the matrix
 * @param out - The calculated rotation matrix
 */
OZZ_INLINE void rotationQuaternion(const Quaternion& quaternion, Matrix3x3& out) {
    auto& oe = out.elements;
    const auto& x = quaternion.x;
    const auto& y = quaternion.y;
    const auto& z = quaternion.z;
    const auto& w = quaternion.w;
    const auto x2 = x + x;
    const auto y2 = y + y;
    const auto z2 = z + z;
    const auto xx = x * x2;
    const auto yx = y * x2;
    const auto yy = y * y2;
    const auto zx = z * x2;
    const auto zy = z * y2;
    const auto zz = z * z2;
    const auto wx = w * x2;
    const auto wy = w * y2;
    const auto wz = w * z2;
    
    oe[0] = 1 - yy - zz;
    oe[3] = yx - wz;
    oe[6] = zx + wy;
    
    oe[1] = yx + wz;
    oe[4] = 1 - xx - zz;
    oe[7] = zy - wx;
    
    oe[2] = zx - wy;
    oe[5] = zy + wx;
    oe[8] = 1 - xx - yy;
}

/**
 * Calculate a matrix from scale vector.
 * @param s - The scale vector
 * @param out - The calculated matrix
 */
OZZ_INLINE void scaling(const Float2& s, Matrix3x3& out) {
    auto& oe = out.elements;
    
    oe[0] = s.x;
    oe[1] = 0;
    oe[2] = 0;
    
    oe[3] = 0;
    oe[4] = s.y;
    oe[5] = 0;
    
    oe[6] = 0;
    oe[7] = 0;
    oe[8] = 1;
}

/**
 * Calculate a matrix from translation vector.
 * @param translation - The translation vector
 * @param out - The calculated matrix
 */
OZZ_INLINE void translation(const Float2& translation, Matrix3x3& out) {
    auto& oe = out.elements;
    
    oe[0] = 1;
    oe[1] = 0;
    oe[2] = 0;
    
    oe[3] = 0;
    oe[4] = 1;
    oe[5] = 0;
    
    oe[6] = translation.x;
    oe[7] = translation.y;
    oe[8] = 1;
}

/**
 * Calculate the inverse of the specified matrix.
 * @param a - The matrix whose inverse is to be calculated
 * @param out - The inverse of the specified matrix
 */
OZZ_INLINE void invert(const Matrix3x3& a, Matrix3x3& out) {
    const auto& ae = a.elements;
    auto& oe = out.elements;
    
    const auto& a11 = ae[0],
    a12 = ae[1],
    a13 = ae[2];
    const auto& a21 = ae[3],
    a22 = ae[4],
    a23 = ae[5];
    const auto& a31 = ae[6],
    a32 = ae[7],
    a33 = ae[8];
    
    const auto b12 = a33 * a22 - a23 * a32;
    const auto b22 = -a33 * a21 + a23 * a31;
    const auto b32 = a32 * a21 - a22 * a31;
    
    auto det = a11 * b12 + a12 * b22 + a13 * b32;
    if (!det) {
        return;
    }
    det = 1.0 / det;
    
    oe[0] = b12 * det;
    oe[1] = (-a33 * a12 + a13 * a32) * det;
    oe[2] = (a23 * a12 - a13 * a22) * det;
    
    oe[3] = b22 * det;
    oe[4] = (a33 * a11 - a13 * a31) * det;
    oe[5] = (-a23 * a11 + a13 * a21) * det;
    
    oe[6] = b32 * det;
    oe[7] = (-a32 * a11 + a12 * a31) * det;
    oe[8] = (a22 * a11 - a12 * a21) * det;
}

/**
 * Calculate a 3x3 normal matrix from a 4x4 matrix.
 * @remarks The calculation process is the transpose matrix of the inverse matrix.
 * @param mat4 - The 4x4 matrix
 * @param out - THe 3x3 normal matrix
 */
OZZ_INLINE void normalMatrix(const Matrix& mat4, Matrix3x3& out);
/**
 * The specified matrix rotates around an angle.
 * @param a - The specified matrix
 * @param r - The rotation angle in radians
 * @param out - The rotated matrix
 */
OZZ_INLINE void rotate(const Matrix3x3& a, float r, Matrix3x3& out) {
    const auto& ae = a.elements;
    auto& oe = out.elements;
    const auto s = std::sin(r);
    const auto c = std::cos(r);
    
    const auto a11 = ae[0],
    a12 = ae[1],
    a13 = ae[2];
    const auto a21 = ae[3],
    a22 = ae[4],
    a23 = ae[5];
    const auto a31 = ae[6],
    a32 = ae[7],
    a33 = ae[8];
    
    oe[0] = c * a11 + s * a21;
    oe[1] = c * a12 + s * a22;
    oe[2] = c * a13 + s * a23;
    
    oe[3] = c * a21 - s * a11;
    oe[4] = c * a22 - s * a12;
    oe[5] = c * a23 - s * a13;
    
    oe[6] = a31;
    oe[7] = a32;
    oe[8] = a33;
}

/**
 * Scale a matrix by a given vector.
 * @param m - The matrix
 * @param s - The given vector
 * @param out - The scaled matrix
 */
OZZ_INLINE void scale(const Matrix3x3& m, const Float2& s, Matrix3x3& out) {
    const auto& x = s.x;
    const auto& y = s.y;
    const auto& ae = m.elements;
    auto& oe = out.elements;
    
    oe[0] = x * ae[0];
    oe[1] = x * ae[1];
    oe[2] = x * ae[2];
    
    oe[3] = y * ae[3];
    oe[4] = y * ae[4];
    oe[5] = y * ae[5];
    
    oe[6] = ae[6];
    oe[7] = ae[7];
    oe[8] = ae[8];
}

/**
 * Translate a matrix by a given vector.
 * @param m - The matrix
 * @param translation - The given vector
 * @param out - The translated matrix
 */
OZZ_INLINE void translate(const Matrix3x3& m, const Float2& translation, Matrix3x3& out) {
    const auto& x = translation.x;
    const auto& y = translation.y;
    const auto& ae = m.elements;
    auto& oe = out.elements;
    
    const auto& a11 = ae[0],
    a12 = ae[1],
    a13 = ae[2];
    const auto& a21 = ae[3],
    a22 = ae[4],
    a23 = ae[5];
    const auto& a31 = ae[6],
    a32 = ae[7],
    a33 = ae[8];
    
    oe[0] = a11;
    oe[1] = a12;
    oe[2] = a13;
    
    oe[3] = a21;
    oe[4] = a22;
    oe[5] = a23;
    
    oe[6] = x * a11 + y * a21 + a31;
    oe[7] = x * a12 + y * a22 + a32;
    oe[8] = x * a13 + y * a23 + a33;
}

/**
 * Calculate the transpose of the specified matrix.
 * @param a - The specified matrix
 * @param out - The transpose of the specified matrix
 */
OZZ_INLINE void transpose(const Matrix3x3& a, Matrix3x3& out) {
    const auto& ae = a.elements;
    auto& oe = out.elements;
    
    if (&out == &a) {
        const auto& a12 = ae[1];
        const auto& a13 = ae[2];
        const auto& a23 = ae[5];
        oe[1] = ae[3];
        oe[2] = ae[6];
        oe[3] = a12;
        oe[5] = ae[7];
        oe[6] = a13;
        oe[7] = a23;
    } else {
        oe[0] = ae[0];
        oe[1] = ae[3];
        oe[2] = ae[6];
        
        oe[3] = ae[1];
        oe[4] = ae[4];
        oe[5] = ae[7];
        
        oe[6] = ae[2];
        oe[7] = ae[5];
        oe[8] = ae[8];
    }
}

}
}

#endif /* matrix3x3_hpp */
