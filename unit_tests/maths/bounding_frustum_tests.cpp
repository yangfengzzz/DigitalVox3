//
//  bounding_frustum_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/26.
//

#include "maths/bounding_frustum.h"
#include "maths/bounding_sphere.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using namespace ozz::math;

class BoundingFrustumTest : public testing::Test {
public:
    void SetUp() override {
        viewMatrix = Matrix(1, 0, 0, 0,
                            0, 1, 0, 0,
                            0, 0, 1, 0,
                            0, 0, -20, 1);
        projectionMatrix = Matrix(0.03954802080988884, 0, 0, 0,
                                  0, 0.10000000149011612, 0, 0,
                                  0, 0, -0.0200200192630291, 0,
                                  -0, -0, -1.0020020008087158, 1);
        vpMatrix = projectionMatrix * viewMatrix;
        frustum = BoundingFrustum(vpMatrix);
    }
    
    Matrix viewMatrix;
    Matrix projectionMatrix;
    Matrix vpMatrix;
    BoundingFrustum frustum;
};

TEST_F(BoundingFrustumTest, intersectsBox) {
    const auto box1 = BoundingBox(Float3(-2, -2, -2), Float3(2, 2, 2));
    const auto flag1 = frustum.intersectsBox(box1);
    EXPECT_EQ(flag1, true);
    
    const auto box2 = BoundingBox(Float3(-32, -2, -2), Float3(-28, 2, 2));
    const auto flag2 = frustum.intersectsBox(box2);
    EXPECT_EQ(flag2, false);
}

TEST_F(BoundingFrustumTest, intersectsSphere) {
    const auto box1 = BoundingBox(Float3(-2, -2, -2), Float3(2, 2, 2));
    const auto sphere1 = BoundingSphere::fromBox(box1);
    const auto flag1 = frustum.intersectsSphere(sphere1);
    EXPECT_EQ(flag1, true);
    
    const auto box2 = BoundingBox(Float3(-32, -2, -2), Float3(-28, 2, 2));
    const auto sphere2 = BoundingSphere::fromBox(box2);
    const auto flag2 = frustum.intersectsSphere(sphere2);
    EXPECT_EQ(flag2, false);
}

TEST_F(BoundingFrustumTest, calculateFromMatrix) {
    auto a = BoundingFrustum();
    a.calculateFromMatrix(vpMatrix);
    
    for (int i = 0; i < 6; ++i) {
        const auto aPlane = a.getPlane(i);
        const auto bPlane = frustum.getPlane(i);
        
        EXPECT_EQ(aPlane.distance, bPlane.distance);
        EXPECT_EQ(aPlane.normal, bPlane.normal);
    }
}

TEST(Plane, Constructor) {
    const auto point1 = Float3(0, 1, 0);
    const auto point2 = Float3(0, 1, 1);
    const auto point3 = Float3(1, 1, 0);
    auto plane1 = Plane::fromPoints(point1, point2, point3);
    auto plane2 = Plane(Float3(0, 1, 0), -1);

    EXPECT_EQ(plane1.distance, plane2.distance);
    plane1.normalize();
    plane2.normalize();
    EXPECT_EQ(plane1.normal, plane2.normal);
}
