//
//  quaternion_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/25.
//

#include "maths/quaternion.h"
#include "maths/matrix3x3.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using ozz::math::Float3;
using ozz::math::Quaternion;
using ozz::math::Matrix3x3;

TEST(Quaternion, add) {
    const auto a = Quaternion(2, 3, 4, 1);
    const auto b = Quaternion(-3, 5, 0, 2);
    const auto out =  a + b;
    EXPECT_QUATERNION_EQ(out, -1, 8, 4, 3);
}

TEST(Quaternion, multiply) {
    const auto a = Quaternion(2, 3, 4, 1);
    const auto b = Quaternion(-3, 5, 0, 2);
    const auto out = a * b;
    
    EXPECT_QUATERNION_EQ(out, -19, -1, 27, -7);
}

TEST(Quaternion, conjugate) {
    const auto a = Quaternion(2, 3, 4, 5);
    const auto out = Conjugate(a);
    EXPECT_QUATERNION_EQ(out, -2, -3, -4, 5);
}

TEST(Quaternion, dot) {
    const auto a = Quaternion(2, 3, 1, 1);
    const auto b = Quaternion(-4, 5, 1, 1);
    
    EXPECT_FLOAT_EQ(Dot(a, b), 9);
}

TEST(Quaternion, equals) {
    const auto a = Quaternion(1, 2, 3, 4);
    const auto b = Quaternion(1 + ozz::math::kNormalizationToleranceSq * 0.9, 2, 3, 4);
    
    EXPECT_QUATERNION_EQ(a, b.x, b.y, b.z, b.w);
}

TEST(Quaternion, rotationAxisAngle) {
    auto a = Float3(3, 7, 5);
    a = Normalize(a);
    const auto out = Quaternion::FromAxisAngle(a, M_PI / 3);
    const auto b = ToAxisAngle(out);
    
    EXPECT_FLOAT_EQ(b.w, M_PI / 3);
    EXPECT_FLOAT3_EQ(Normalize(Float3(b.x, b.y, b.z)), a.x, a.y, a.z);
}

TEST(Quaternion, rotationYawPitchRoll) {
    const auto out = Quaternion::FromEuler(0, M_PI / 3, M_PI / 2);
    const auto b = ToEuler(out);
    EXPECT_FLOAT3_EQ(b, 0, M_PI / 3, M_PI / 2);
}

TEST(Quaternion, rotationMatrix3x3) {
    const auto a1 = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    const auto a2 = Matrix3x3(1, 2, 3, 4, -5, 6, 7, 8, -9);
    const auto a3 = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, -9);
    const auto a4 = Matrix3x3(-7, 2, 3, 4, -5, 6, 7, 8, 9);
    
    auto out = Quaternion::rotationMatrix3x3(a1);
    EXPECT_QUATERNION_EQ(out, -0.25, 0.5, -0.25, 2);
    out = Quaternion::rotationMatrix3x3(a2);
    EXPECT_QUATERNION_EQ(out, 2, 0.75, 1.25, -0.25);
    out = Quaternion::rotationMatrix3x3(a3);
    EXPECT_QUATERNION_EQ(out, 0.8017837257372732, 1.8708286933869707, 1.8708286933869709, 0.5345224838248488);
    out = Quaternion::rotationMatrix3x3(a4);
    EXPECT_QUATERNION_EQ(out, 1.066003581778052, 1.4924050144892729, 2.345207879911715, -0.21320071635561041);
}

TEST(Quaternion, invert) {
    const auto a = Quaternion(1, 1, 1, 0.5);
    const auto out = invert(a);
    EXPECT_QUATERNION_EQ(out, -0.3076923076923077, -0.3076923076923077, -0.3076923076923077, 0.15384615384615385);
}
