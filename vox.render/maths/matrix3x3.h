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

namespace vox {
namespace math {
struct Matrix;
struct Matrix3x3;

VOX_INLINE Matrix3x3 invert(const Matrix3x3 &a);

VOX_INLINE Matrix3x3 rotate(const Matrix3x3 &a, float r);

VOX_INLINE Matrix3x3 scale(const Matrix3x3 &m, const Float2 &s);

VOX_INLINE Matrix3x3 translate(const Matrix3x3 &m, const Float2 &translation);

VOX_INLINE Matrix3x3 transpose(const Matrix3x3 &a);

// Represents a 3x3 mathematical matrix.
struct Matrix3x3 {
    std::array<float, 9> elements;
    
    /**
     * Calculate a rotation matrix from a quaternion.
     * @param quaternion - The quaternion used to calculate the matrix
     * @return out - The calculated rotation matrix
     */
    static VOX_INLINE Matrix3x3 rotationQuaternion(const Quaternion &quaternion) {
        const auto &x = quaternion.x;
        const auto &y = quaternion.y;
        const auto &z = quaternion.z;
        const auto &w = quaternion.w;
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
        
        return Matrix3x3(1 - yy - zz,
                         yx + wz,
                         zx - wy,
                         
                         yx - wz,
                         1 - xx - zz,
                         zy + wx,
                         
                         zx + wy,
                         zy - wx,
                         1 - xx - yy);
    }
    
    /**
     * Calculate a matrix from scale vector.
     * @param s - The scale vector
     * @return  out - The calculated matrix
     */
    static VOX_INLINE Matrix3x3 scaling(const Float2 &s) {
        return Matrix3x3(s.x,
                         0,
                         0,
                         
                         0,
                         s.y,
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
    static VOX_INLINE Matrix3x3 translation(const Float2 &translation) {
        return Matrix3x3(1,
                         0,
                         0,
                         
                         0,
                         1,
                         0,
                         
                         translation.x,
                         translation.y,
                         1);
    }
    
    
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
    VOX_INLINE Matrix3x3(float m11 = 1,
                         float m12 = 0,
                         float m13 = 0,
                         float m21 = 0,
                         float m22 = 1,
                         float m23 = 0,
                         float m31 = 0,
                         float m32 = 0,
                         float m33 = 1) {
        auto &e = elements;
        
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
     * Set the value of this 3x3 matrix by the specified 4x4 matrix.
     * upper-left principle
     * @param a - The specified 4x4 matrix
     */
    void setValueByMatrix(const Matrix& a);
    
    /**
     * Calculate a determinant of this matrix.
     * @returns The determinant of this matrix
     */
    VOX_INLINE float determinant() const {
        auto &e = elements;
        
        const auto &a11 = e[0],
        a12 = e[1],
        a13 = e[2];
        const auto &a21 = e[3],
        a22 = e[4],
        a23 = e[5];
        const auto &a31 = e[6],
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
    VOX_INLINE void identity() {
        auto &e = elements;
        
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
        *this = ::vox::math::invert(*this);
    }
    
    /**
     * This matrix rotates around an angle.
     * @param r - The rotation angle in radians
     */
    void rotate(float r) {
        *this = ::vox::math::rotate(*this, r);
    }
    
    /**
     * Scale this matrix by a given vector.
     * @param s - The given vector
     */
    void scale(const Float2 &s) {
        *this = ::vox::math::scale(*this, s);
    }
    
    /**
     * Translate this matrix by a given vector.
     * @param translation - The given vector
     */
    void translate(const Float2 &translation) {
        *this = ::vox::math::translate(*this, translation);
    }
    
    /**
     * Calculate the transpose of this matrix.
     */
    void transpose() {
        *this = ::vox::math::transpose(*this);
    }
};

VOX_INLINE Matrix3x3 operator+(const Matrix3x3 &left, const Matrix3x3 &right) {
    const auto &le = left.elements;
    const auto &re = right.elements;
    Matrix3x3 out;
    auto &oe = out.elements;
    
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

VOX_INLINE Matrix3x3 operator-(const Matrix3x3 &left, const Matrix3x3 &right) {
    const auto &le = left.elements;
    const auto &re = right.elements;
    Matrix3x3 out;
    auto &oe = out.elements;
    
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

VOX_INLINE Matrix3x3 operator*(const Matrix3x3 &left, const Matrix3x3 &right) {
    const auto &le = left.elements;
    const auto &re = right.elements;
    Matrix3x3 out;
    auto &oe = out.elements;
    
    const auto &l11 = le[0],
    l12 = le[1],
    l13 = le[2];
    const auto &l21 = le[3],
    l22 = le[4],
    l23 = le[5];
    const auto &l31 = le[6],
    l32 = le[7],
    l33 = le[8];
    
    const auto &r11 = re[0],
    r12 = re[1],
    r13 = re[2];
    const auto &r21 = re[3],
    r22 = re[4],
    r23 = re[5];
    const auto &r31 = re[6],
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

VOX_INLINE bool operator==(const Matrix3x3 &left, const Matrix3x3 &right) {
    const auto &le = left.elements;
    const auto &re = right.elements;
    
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
 * @return out - The result of linear blending between two matrices
 */
VOX_INLINE Matrix3x3 lerp(const Matrix3x3 &start, const Matrix3x3 &end, float t) {
    const auto &se = start.elements;
    const auto &ee = end.elements;
    const auto inv = 1.0 - t;
    
    return Matrix3x3(se[0] * inv + ee[0] * t,
                     se[1] * inv + ee[1] * t,
                     se[2] * inv + ee[2] * t,
                     
                     se[3] * inv + ee[3] * t,
                     se[4] * inv + ee[4] * t,
                     se[5] * inv + ee[5] * t,
                     
                     se[6] * inv + ee[6] * t,
                     se[7] * inv + ee[7] * t,
                     se[8] * inv + ee[8] * t);
}


/**
 * Calculate the inverse of the specified matrix.
 * @param a - The matrix whose inverse is to be calculated
 * @return out - The inverse of the specified matrix
 */
VOX_INLINE Matrix3x3 invert(const Matrix3x3 &a) {
    const auto &ae = a.elements;
    const auto &a11 = ae[0],
    a12 = ae[1],
    a13 = ae[2];
    const auto &a21 = ae[3],
    a22 = ae[4],
    a23 = ae[5];
    const auto &a31 = ae[6],
    a32 = ae[7],
    a33 = ae[8];
    
    const auto b12 = a33 * a22 - a23 * a32;
    const auto b22 = -a33 * a21 + a23 * a31;
    const auto b32 = a32 * a21 - a22 * a31;
    
    auto det = a11 * b12 + a12 * b22 + a13 * b32;
    if (!det) {
        return Matrix3x3();
    }
    det = 1.0 / det;
    
    return Matrix3x3(b12 * det,
                     (-a33 * a12 + a13 * a32) * det,
                     (a23 * a12 - a13 * a22) * det,
                     
                     b22 * det,
                     (a33 * a11 - a13 * a31) * det,
                     (-a23 * a11 + a13 * a21) * det,
                     
                     b32 * det,
                     (-a32 * a11 + a12 * a31) * det,
                     (a22 * a11 - a12 * a21) * det);
}

/**
 * Calculate a 3x3 normal matrix from a 4x4 matrix.
 * @remarks The calculation process is the transpose matrix of the inverse matrix.
 * @param mat4 - The 4x4 matrix
 * @return out - THe 3x3 normal matrix
 */
Matrix3x3 normalMatrix(const Matrix &mat4);

/**
 * The specified matrix rotates around an angle.
 * @param a - The specified matrix
 * @param r - The rotation angle in radians
 * @return out - The rotated matrix
 */
VOX_INLINE Matrix3x3 rotate(const Matrix3x3 &a, float r) {
    const auto &ae = a.elements;
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
    
    return Matrix3x3(c * a11 + s * a21,
                     c * a12 + s * a22,
                     c * a13 + s * a23,
                     
                     c * a21 - s * a11,
                     c * a22 - s * a12,
                     c * a23 - s * a13,
                     
                     a31,
                     a32,
                     a33);
}

/**
 * Scale a matrix by a given vector.
 * @param m - The matrix
 * @param s - The given vector
 * @return out - The scaled matrix
 */
VOX_INLINE Matrix3x3 scale(const Matrix3x3 &m, const Float2 &s) {
    const auto &x = s.x;
    const auto &y = s.y;
    const auto &ae = m.elements;
    
    return Matrix3x3(x * ae[0],
                     x * ae[1],
                     x * ae[2],
                     
                     y * ae[3],
                     y * ae[4],
                     y * ae[5],
                     
                     ae[6],
                     ae[7],
                     ae[8]);
}

/**
 * Translate a matrix by a given vector.
 * @param m - The matrix
 * @param translation - The given vector
 * @return out - The translated matrix
 */
VOX_INLINE Matrix3x3 translate(const Matrix3x3 &m, const Float2 &translation) {
    const auto &x = translation.x;
    const auto &y = translation.y;
    const auto &ae = m.elements;
    
    const auto &a11 = ae[0],
    a12 = ae[1],
    a13 = ae[2];
    const auto &a21 = ae[3],
    a22 = ae[4],
    a23 = ae[5];
    const auto &a31 = ae[6],
    a32 = ae[7],
    a33 = ae[8];
    
    return Matrix3x3(a11,
                     a12,
                     a13,
                     
                     a21,
                     a22,
                     a23,
                     
                     x * a11 + y * a21 + a31,
                     x * a12 + y * a22 + a32,
                     x * a13 + y * a23 + a33);
}

/**
 * Calculate the transpose of the specified matrix.
 * @param a - The specified matrix
 * @return out - The transpose of the specified matrix
 */
VOX_INLINE Matrix3x3 transpose(const Matrix3x3 &a) {
    const auto &ae = a.elements;
    return Matrix3x3(ae[0],
                     ae[3],
                     ae[6],
                     
                     ae[1],
                     ae[4],
                     ae[7],
                     
                     ae[2],
                     ae[5],
                     ae[8]);
}

}
}

#endif /* matrix3x3_hpp */
