//
//  vector3_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/25.
//

#include "maths/vec_float.h"
#include "maths/matrix.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using vox::math::Float3;
using vox::math::Float4;
using vox::math::Quaternion;
using vox::math::Matrix;

TEST(Vector3, add) {
    const auto a = Float3(2, 3, 4);
    const auto b = Float3(-3, 5, 0);
    const auto out = a + b;
    
    EXPECT_FLOAT3_EQ(out, -1, 8, 4);
}

TEST(Vector3, subtract) {
    const auto a = Float3(2, 3, 4);
    const auto b = Float3(-3, 5, 1);
    const auto out = a - b;
    
    EXPECT_FLOAT3_EQ(out, 5, -2, 3);
}

TEST(Vector3, multiply) {
    const auto a = Float3(2, 3, 4);
    const auto b = Float3(-3, 5, 0.2);
    const auto out = a * b;
    
    EXPECT_FLOAT3_EQ(out, -6, 15, 0.8);
}

TEST(Vector3, divide) {
    const auto a = Float3(2, 3, 4);
    const auto b = Float3(-4, 5, 16);
    const auto out = a / b;
    
    EXPECT_FLOAT3_EQ(out, -0.5, 0.6, 0.25);
}

TEST(Vector3, dot) {
    const auto a = Float3(2, 3, 1);
    const auto b = Float3(-4, 5, 1);
    
    EXPECT_FLOAT_EQ(Dot(a, b), 8);
}

TEST(Vector3, cross) {
    const auto a = Float3(1, 2, 3);
    const auto b = Float3(4, 5, 6);
    const auto out = Cross(a, b);
    EXPECT_FLOAT3_EQ(out, -3, 6, -3);
}

TEST(Vector3, distance) {
    const auto a = Float3(1, 2, 3);
    const auto b = Float3(4, 6, 3);
    
    EXPECT_FLOAT_EQ(Length(a - b), 5);
    EXPECT_FLOAT_EQ(LengthSqr(a - b), 25);
}

TEST(Vector3, equals) {
    const auto a = Float3(1, 2, 3);
    const auto b = Float3(1 + vox::math::kNormalizationToleranceSq * 0.9, 2, 3);
    
    EXPECT_FLOAT3_EQ(a, b.x, b.y, b.z);
}

TEST(Vector3, lerp) {
    const auto a = Float3(0, 1, 2);
    const auto b = Float3(2, 2, 0);
    const auto out = Lerp(a, b, 0.5);
    EXPECT_FLOAT3_EQ(out, 1, 1.5, 1);
}

TEST(Vector3, max) {
    const auto a = Float3(0, 10, 1);
    const auto b = Float3(2, 3, 5);
    const auto out = Max(a, b);
    EXPECT_FLOAT3_EQ(out, 2, 10, 5);
}

TEST(Vector3, min) {
    const auto a = Float3(0, 10, 1);
    const auto b = Float3(2, 3, 5);
    const auto out = Min(a, b);
    EXPECT_FLOAT3_EQ(out, 0, 3, 1);
}

TEST(Vector3, negate) {
    const auto a = Float3(4, -4, 0);
    const auto out = -a;
    
    EXPECT_FLOAT3_EQ(out, -4, 4, 0);
}

TEST(Vector3, normalize) {
    const auto a = Float3(3, 4, 0);
    const auto out = Normalize(a);
    EXPECT_FLOAT3_EQ(out, 0.6, 0.8, 0);
}

TEST(Vector3, scale) {
    const auto a = Float3(3, 4, 5);
    const auto out = a * 3;
    EXPECT_FLOAT3_EQ(out, 9, 12, 15);
}

TEST(Vector3, transform) {
    const auto a = Float3(2, 3, 4);
    const auto m44 = Matrix(2, 7, 17, 0, 3, 11, 19, 0, 5, 13, 23, 0, 0, 0, 0, 1);
    Float3 out = transformNormal(a, m44);
    EXPECT_FLOAT3_EQ(out, 33, 99, 183);
    
    const auto b = Float4(2, 3, 4, 1);
    const auto m4 = Matrix(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1);
    out = transformCoordinate(a, m4);
    const auto out4 = transform(b, m4);
    EXPECT_FLOAT_EQ(out.x, out4.x / out4.w);
    EXPECT_FLOAT_EQ(out.y, out4.y / out4.w);
    EXPECT_FLOAT_EQ(out.z, out4.z / out4.w);
    
    out = transformByQuat(a, Quaternion());
    EXPECT_FLOAT3_EQ(a, out.x, out.y, out.z);
    out = transformByQuat(a, Quaternion(2, 3, 4, 5));
    EXPECT_FLOAT3_EQ(out, 108, 162, 216);
}
