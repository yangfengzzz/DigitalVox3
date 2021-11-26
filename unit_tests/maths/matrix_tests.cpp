//
//  matrix_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/25.
//

#include "maths/matrix.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using ozz::math::Float3;
using ozz::math::Matrix;
using ozz::math::Quaternion;

TEST(Matrix, multiply) {
    const auto a = Matrix(1, 2, 3.3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 13, 14, 15, 16);
    const auto b = Matrix(16, 15, 14, 13, 12, 11, 10, 9, 8.88, 7, 6, 5, 4, 3, 2, 1);
    const Matrix out = a * b;
    EXPECT_MATRIX_EQ(out,
                     386,
                     456.59997558,
                     506.8,
                     560,
                     274,
                     325,
                     361.6,
                     400,
                     162.88,
                     195.16000000000003,
                     219.304,
                     243.52,
                     50,
                     61.8,
                     71.2,
                     80);
}

TEST(Matrix, lerp) {
    const auto a = Matrix(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16);
    const auto b = Matrix(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16);
    const auto c = Lerp(a, b, 0.7);
    EXPECT_MATRIX_EQ(c, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16);
}

TEST(Matrix, rotationQuaternion) {
    const auto q = Quaternion(1, 2, 3, 4);
    const auto out = Matrix::rotationQuaternion(q);
    EXPECT_MATRIX_EQ(out, -25, 28, -10, 0, -20, -19, 20, 0, 22, 4, -9, 0, 0, 0, 0, 1);
}

TEST(Matrix, rotationAxisAngle) {
    const auto out = Matrix::rotationAxisAngle(Float3(0, 1, 0), M_PI / 3);
    EXPECT_MATRIX_EQ(out,
                     0.5000000000000001,
                     0,
                     -0.8660254037844386,
                     0,
                     0,
                     1,
                     0,
                     0,
                     0.8660254037844386,
                     0,
                     0.5000000000000001,
                     0,
                     0,
                     0,
                     0,
                     1);
}

TEST(Matrix, rotationTranslation) {
    const auto q = Quaternion(1, 0.5, 2, 1);
    const auto v = Float3(1, 1, 1);
    const auto out = Matrix::rotationTranslation(q, v);
    EXPECT_MATRIX_EQ(out, -7.5, 5, 3, 0, -3, -9, 4, 0, 5, 0, -1.5, 0, 1, 1, 1, 1);
}

TEST(Matrix, affineTransformation) {
    const auto q = Quaternion(1, 0.5, 2, 1);
    const auto v = Float3(1, 1, 1);
    const auto s = Float3(1, 0.5, 2);
    const auto out = Matrix::affineTransformation(s, q, v);
    EXPECT_MATRIX_EQ(out, -7.5, 5, 3, 0, -1.5, -4.5, 2, 0, 10, 0, -3, 0, 1, 1, 1, 1);
}

TEST(Matrix, scaling) {
    const auto a = Matrix();
    const auto out = scale(a, Float3(1, 2, 0.5));
    EXPECT_MATRIX_EQ(out, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 1);
}

TEST(Matrix, translation) {
    const auto v = Float3(1, 2, 0.5);
    const auto out = Matrix::translation(v);
    EXPECT_MATRIX_EQ(out, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 2, 0.5, 1);
}

TEST(Matrix, invert) {
    const auto a = Matrix(1, 2, 3.3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 13, 14, 15, 16);
    const auto out = invert(a);
    EXPECT_MATRIX_EQ(out,
                     -1.1111111111111172,
                     1.3703594207763672,
                     -0.7407407407407528,
                     0.1481481481481532,
                     0,
                     -0.5555555555555607,
                     1.1110992431640625,
                     -0.5555555555555607,
                     3.3333001136779785,
                     -4.9999480247497559,
                     0,
                     1.6666476726531982,
                     -2.222196102142334,
                     4.0601420402526855,
                     -0.3703703703703687,
                     -1.1342480182647705
                     );
}

TEST(Matrix, lookAt) {
    auto eye = Float3(0, 0, -8);
    auto target = Float3(0, 0, 0);
    auto up = Float3(0, 1, 0);
    auto out = Matrix::lookAt(eye, target, up);
    EXPECT_MATRIX_EQ(out, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, -8, 1);
    
    eye = Float3(0, 0, 0);
    target = Float3(0, 1, -1);
    up = Float3(0, 1, 0);
    out = Matrix::lookAt(eye, target, up);
    EXPECT_MATRIX_EQ(out,
                     1,
                     0,
                     0,
                     0,
                     0,
                     0.7071067690849304,
                     -0.7071067690849304,
                     0,
                     0,
                     0.7071067690849304,
                     0.7071067690849304,
                     0,
                     0,
                     0,
                     0,
                     1
                     );
}

TEST(Matrix, ortho) {
    const auto out = Matrix::ortho(0, 2, -1, 1, 0.1, 100);
    EXPECT_MATRIX_EQ(out, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -0.02002002002002002, 0, -1, 0, -1.002002002002002, 1);
}

TEST(Matrix, perspective) {
    const auto out = Matrix::perspective(1, 1.5, 0.1, 100);
    EXPECT_MATRIX_EQ(out,
                     1.2203251478083013,
                     0,
                     0,
                     0,
                     0,
                     1.830487721712452,
                     0,
                     0,
                     0,
                     0,
                     -1.002002002002002,
                     -1,
                     0,
                     0,
                     -0.20020020020020018,
                     0
                     );
}

TEST(Matrix, rotateAxisAngle) {
    const auto a = Matrix(1, 2, 3.3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 13, 14, 15, 16);
    const auto out = rotateAxisAngle(a, Float3(0, 1, 0), M_PI / 3);
    EXPECT_MATRIX_EQ(out,
                     -7.294228634059947,
                     -8.439676901250381,
                     -7.876279441628824,
                     -8.392304845413264,
                     5,
                     6,
                     7,
                     8,
                     5.366025403784439,
                     7.182050807568878,
                     8.357883832488648,
                     9.464101615137757,
                     13,
                     14,
                     15,
                     16
                     );
}

TEST(Matrix, scale) {
    const auto a = Matrix(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16);
    const auto out = scale(a, Float3(1, 2, 0.5));
    EXPECT_MATRIX_EQ(out, 1, 2, 3, 4, 10, 12, 14, 16, 4.5, 5, 5.5, 6, 13, 14, 15, 16);
}

TEST(Matrix, translate) {
    const auto a = Matrix(1, 2, 3.3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 13, 14, 15, 16);
    const auto out = translate(a, Float3(1, 2, 0.5));
    EXPECT_MATRIX_EQ(out, 1, 2, 3.3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 28.5, 33.45, 37.8, 42);
}

TEST(Matrix, transpose) {
    const auto a = Matrix(1, 2, 3.3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 13, 14, 15, 16);
    const auto out = transpose(a);
    EXPECT_MATRIX_EQ(out, 1, 5, 9, 13, 2, 6, 10.9, 14, 3.3, 7, 11, 15, 4, 8, 12, 16);
}

TEST(Matrix, determinant) {
    const auto a = Matrix(1, 2, 3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 13, 14, 15, 16);
    EXPECT_FLOAT_EQ(a.determinant(), -6.1035156e-05);
}

TEST(Matrix, decompose) {
    const auto a = Matrix(1, 2, 3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 13, 14, 15, 16);
    // const a = new Matrix(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0);
    auto pos = Float3();
    auto quat = Quaternion();
    auto scale = Float3();
    
    a.decompose(pos, quat, scale);
    EXPECT_FLOAT3_EQ(pos, 13, 14, 15);
    EXPECT_QUATERNION_EQ(quat, 0.01879039477474769, -0.09554131404261303, 0.01844761344901482, 0.783179537258594);
    EXPECT_FLOAT3_EQ(scale, 3.7416573867739413, 10.488088481701515, 17.91116946723357);
}

TEST(Matrix, getXXX) {
    const auto a = Matrix(1, 2, 3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 13, 14, 15, 16);
    
    // getRotation
    auto quat = a.getRotation();
    EXPECT_QUATERNION_EQ(quat, -0.44736068104759547, 0.6882472016116852, -0.3441236008058426, 2.179449471770337);
    
    // getScaling
    auto scale = a.getScaling();
    EXPECT_FLOAT3_EQ(scale, 3.7416573867739413, 10.488088481701515, 17.911169699380327);
    
    // getTranslation
    auto translation = a.getTranslation();
    EXPECT_FLOAT3_EQ(translation, 13, 14, 15);
}
