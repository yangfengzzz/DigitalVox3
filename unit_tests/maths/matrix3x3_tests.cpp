//
//  matrix3x3_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/26.
//

#include "maths/matrix3x3.h"
#include "maths/matrix.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using vox::math::Matrix3x3;
using vox::math::Matrix;
using vox::math::Quaternion;
using vox::math::Float2;

TEST(Matrix3x3, add) {
    const auto a = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    const auto b = Matrix3x3(9, 8, 7, 6, 5, 4, 3, 2, 1);
    const auto out = a + b;
    
    EXPECT_MATRIX3X3_EQ(out, 10, 10, 10, 10, 10, 10, 10, 10, 10);
}

TEST(Matrix3x3, subtract) {
    const auto a = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    const auto b = Matrix3x3(9, 8, 7, 6, 5, 4, 3, 2, 1);
    const auto out = a - b;
    
    EXPECT_MATRIX3X3_EQ(out, -8, -6, -4, -2, 0, 2, 4, 6, 8);
}

TEST(Matrix3x3, multiply) {
    const auto a = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    const auto b = Matrix3x3(9, 8, 7, 6, 5, 4, 3, 2, 1);
    const auto out = a * b;
    
    EXPECT_MATRIX3X3_EQ(out, 90, 114, 138, 54, 69, 84, 18, 24, 30);
}

TEST(Matrix3x3, lerp) {
    const auto a = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    const auto b = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    const auto c = lerp(a, b, 0.78);
    
    EXPECT_MATRIX3X3_EQ(c, 1, 2, 3, 4, 5, 6, 7, 8, 9);
}

TEST(Matrix3x3, fromXXX) {
    const auto a = Matrix(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);
    
    // Matrix
    Matrix3x3 out;
    out.setValueByMatrix(a);
    EXPECT_MATRIX3X3_EQ(out, 1, 2, 3, 5, 6, 7, 9, 10, 11);
    
    // quat
    const auto q = Quaternion(1, 2, 3, 4);
    out = Matrix3x3::rotationQuaternion(q);
    EXPECT_MATRIX3X3_EQ(out, -25, 28, -10, -20, -19, 20, 22, 4, -9);
    
    // scaling
    const auto scale = Float2(1, 2);
    out = Matrix3x3::scaling(scale);
    EXPECT_MATRIX3X3_EQ(out, 1, 0, 0, 0, 2, 0, 0, 0, 1);
    
    // translation
    const auto translation = Float2(2, 3);
    out = Matrix3x3::translation(translation);
    EXPECT_MATRIX3X3_EQ(out, 1, 0, 0, 0, 1, 0, 2, 3, 1);
}

TEST(Matrix3x3, invert) {
    const auto mat3 = Matrix3x3(1, 2, 3, 2, 2, 4, 3, 1, 3);
    
    Matrix3x3 out = invert(mat3);
    EXPECT_MATRIX3X3_EQ(out, 1, -1.5, 1, 3, -3, 1, -2, 2.5, -1);
}

TEST(Matrix3x3, normalMatrix) {
    const auto mat4 = Matrix(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);
    
    Matrix3x3 out = normalMatrix(mat4);
    EXPECT_MATRIX3X3_EQ(out, 1, 0, 0, 0, 1, 0, 0, 0, 1);
}

TEST(Matrix3x3, rotate) {
    const auto mat3 = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    
    Matrix3x3 out = rotate(mat3, M_PI / 3);
    EXPECT_MATRIX3X3_EQ(out, 3.964101552963257,
                        5.330127239227295,
                        6.696152210235596,
                        1.133974552154541,
                        0.7679491639137268,
                        0.4019237756729126,
                        7,
                        8,
                        9
                        );
}

TEST(Matrix3x3, scale) {
    const auto mat3 = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    
    Matrix3x3 out = scale(mat3, Float2(1, 2));
    EXPECT_MATRIX3X3_EQ(out, 1, 2, 3, 8, 10, 12, 7, 8, 9);
}

TEST(Matrix3x3, translate) {
    const auto mat3 = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    auto out = translate(mat3, Float2(1, 2));
    EXPECT_MATRIX3X3_EQ(out, 1, 2, 3, 4, 5, 6, 16, 20, 24);
}

TEST(Matrix3x3, transpose) {
    const auto mat3 = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    
    auto out = transpose(mat3);
    EXPECT_MATRIX3X3_EQ(out, 1, 4, 7, 2, 5, 8, 3, 6, 9);
    out = transpose(out);
    EXPECT_MATRIX3X3_EQ(out, 1, 2, 3, 4, 5, 6, 7, 8, 9);
}

TEST(Matrix3x3, determinant) {
    const auto a = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    EXPECT_FLOAT_EQ(a.determinant(), 0);
}
