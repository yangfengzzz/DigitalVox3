//
//  vector4_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/25.
//

#include "maths/vec_float.h"
#include "maths/matrix.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using ozz::math::Float4;
using ozz::math::Matrix;
using ozz::math::Quaternion;

TEST(Vector4, add) {
    const auto a = Float4(2, 3, 4, 1);
    const auto b = Float4(-3, 5, 0, 2);
    const auto out = a + b;
    
    EXPECT_FLOAT4_EQ(out, -1, 8, 4, 3);
}

TEST(Vector4, subtract) {
    const auto a = Float4(2, 3, 4, 1);
    const auto b = Float4(-3, 5, 1, 2);
    const auto out = a - b;
    
    EXPECT_FLOAT4_EQ(out, 5, -2, 3, -1);
}

TEST(Vector4, multiply) {
    const auto a = Float4(2, 3, 4, 1);
    const auto b = Float4(-3, 5, 0.2, 2);
    const auto out = a * b;
    
    EXPECT_FLOAT4_EQ(out, -6, 15, 0.8, 2);
}

TEST(Vector4, divide) {
    const auto a = Float4(2, 3, 4, 1);
    const auto b = Float4(-4, 5, 16, 2);
    const auto out = a / b;
    
    EXPECT_FLOAT4_EQ(out, -0.5, 0.6, 0.25, 0.5);
}

TEST(Vector4, dot) {
    const auto a = Float4(2, 3, 1, 1);
    const auto b = Float4(-4, 5, 1, 1);
    
    EXPECT_FLOAT_EQ(Dot(a, b), 9);
}

TEST(Vector4, distance) {
    const auto a = Float4(1, 2, 3, 0);
    const auto b = Float4(4, 6, 3, 0);
    
    EXPECT_FLOAT_EQ(Length(a - b), 5);
    EXPECT_FLOAT_EQ(LengthSqr(a - b), 25);
}

TEST(Vector4, equals) {
    const auto a = Float4(1, 2, 3, 4);
    const auto b = Float4(1 + ozz::math::kNormalizationToleranceSq * 0.9, 2, 3, 4);
    
    EXPECT_FLOAT4_EQ(a, b.x, b.y, b.z, b.w);
}

TEST(Vector4, lerp) {
    const auto a = Float4(0, 1, 2, 0);
    const auto b = Float4(2, 2, 0, 0);
    const auto out = Lerp(a, b, 0.5);
    EXPECT_FLOAT4_EQ(out, 1, 1.5, 1, 0);
}

TEST(Vector4, max) {
    const auto a = Float4(0, 10, 1, -1);
    const auto b = Float4(2, 3, 5, -5);
    const auto out = Max(a, b);
    EXPECT_FLOAT4_EQ(out, 2, 10, 5, -1);
}

TEST(Vector4, min) {
    const auto a = Float4(0, 10, 1, -1);
    const auto b = Float4(2, 3, 5, -5);
    const auto out = Min(a, b);
    EXPECT_FLOAT4_EQ(out, 0, 3, 1, -5);
}

TEST(Vector4, negate) {
    const auto a = Float4(4, -4, 0, 1);
    const auto out = -a;
    
    EXPECT_FLOAT4_EQ(out, -4, 4, 0, -1);
}

TEST(Vector4, normalize) {
    const auto a = Float4(3, 4, 0, 0);
    const auto out = Normalize(a);
    EXPECT_FLOAT4_EQ(out, 0.6, 0.8, 0, 0);
}

TEST(Vector4, scale) {
    const auto a = Float4(3, 4, 5, 0);
    const auto out = a * 3;
    EXPECT_FLOAT4_EQ(out, 9, 12, 15, 0);
}

TEST(Vector4, transform) {
    const auto a = Float4(2, 3, 4, 5);
    Float4 out;
    const auto m4 = Matrix(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0);
    transform(a, m4, out);
    EXPECT_FLOAT4_EQ(out, 2, 3, 9, 0);
    
    transformByQuat(a, Quaternion(), out);
    EXPECT_FLOAT4_EQ(a, out.x, out.y, out.z, out.w);
    transformByQuat(a, Quaternion(2, 3, 4, 5), out);
    EXPECT_FLOAT4_EQ(out, 108, 162, 216, 5);
}
