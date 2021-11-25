//
//  vector2_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/25.
//

#include "maths/vec_float.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using ozz::math::Float2;

TEST(Vector2, add) {
    const auto a =  Float2(2, 3);
    const auto b =  Float2(-3, 5);
    const auto out =  a + b;
    EXPECT_FLOAT2_EQ(out, -1, 8);
}

TEST(Vector2, subtract) {
    const auto a = Float2(2, 3);
    const auto b = Float2(-3, 5);
    const auto out = a - b;
    EXPECT_FLOAT2_EQ(out, 5, -2);
}

TEST(Vector2, multiply) {
    const auto a = Float2(2, 3);
    const auto b = Float2(-3, 5);
    const auto out = a * b;
    EXPECT_FLOAT2_EQ(out, -6, 15);
}

TEST(Vector2, divide) {
    const auto a = Float2(2, 3);
    const auto b = Float2(-4, 5);
    const auto out = a / b;
    EXPECT_FLOAT2_EQ(out, -0.5, 0.6);
}

TEST(Vector2, dot) {
    const auto a = Float2(2, 3);
    const auto b = Float2(-4, 5);
    
    EXPECT_FLOAT_EQ(Dot(a, b), 7);
}

TEST(Vector2, distance) {
    const auto a = Float2(1, 1);
    const auto b = Float2(4, 5);
    
    EXPECT_FLOAT_EQ(Length(a - b), 5);
}

TEST(Vector2, distanceSquared) {
    const auto a = Float2(1, 1);
    const auto b = Float2(4, 5);
    
    EXPECT_FLOAT_EQ(LengthSqr(a - b), 25);
}

TEST(Vector2, equals) {
    const auto a = Float2(1, 2);
    const auto b = Float2(1 + ozz::math::kNormalizationToleranceSq * 0.9, 2);
    
    EXPECT_FLOAT2_EQ(a, b.x, b.y);
}

TEST(Vector2, lerp) {
    const auto a = Float2(0, 1);
    const auto b = Float2(2, 3);
    Float2 out = Lerp(a, b, 0.5);
    EXPECT_FLOAT2_EQ(out, 1, 2);
}

TEST(Vector2, max) {
    const auto a = Float2(0, 10);
    const auto b = Float2(2, 3);
    Float2 out = Max(a, b);
    EXPECT_FLOAT2_EQ(out, 2, 10);
}

TEST(Vector2, min) {
    const auto a = Float2(0, 10);
    const auto b = Float2(2, 3);
    Float2 out = Min(a, b);
    EXPECT_FLOAT2_EQ(out, 0, 3);
}

TEST(Vector2, negate) {
    const auto a = Float2(4, -4);
    Float2 out = -a;
    EXPECT_FLOAT2_EQ(out, -4, 4);
}

TEST(Vector2, normalize) {
    const auto a = Float2(3, 4);
    const auto out = Normalize(a);
    
    EXPECT_FLOAT2_EQ(out, 0.6, 0.8);
}

TEST(Vector2, scale) {
    const auto a = Float2(3, 4);
    const auto out = a * 3;
    EXPECT_FLOAT2_EQ(out, 9, 12);
}
