//
//  collision_util_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/26.
//

#include "maths/collision_util.h"
#include "maths/plane.h"
#include "maths/matrix.h"
#include "maths/bounding_frustum.h"
#include "maths/bounding_sphere.h"
#include "maths/ray.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using namespace vox::math;

class CollisionUtilTest : public testing::Test {
public:
    void SetUp() override {
        plane = Plane(Float3(0, 1, 0), -5);
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
    
    Plane plane;
    Matrix viewMatrix;
    Matrix projectionMatrix;
    Matrix vpMatrix;
    BoundingFrustum frustum;
};

TEST_F(CollisionUtilTest, distancePlaneAndPoint) {
    const auto point = Float3(0, 10, 0);
    
    const auto distance = collision_util::distancePlaneAndPoint(plane, point);
    EXPECT_FLOAT_EQ(distance, 5);
}

TEST_F(CollisionUtilTest, intersectsPlaneAndPoint) {
    const auto point1 = Float3(0, 10, 0);
    const auto point2 = Float3(2, 5, -9);
    const auto point3 = Float3(0, 3, 0);
    
    const auto intersection1 = collision_util::intersectsPlaneAndPoint(plane, point1);
    const auto intersection2 = collision_util::intersectsPlaneAndPoint(plane, point2);
    const auto intersection3 = collision_util::intersectsPlaneAndPoint(plane, point3);
    EXPECT_EQ(intersection1, PlaneIntersectionType::Front);
    EXPECT_EQ(intersection2, PlaneIntersectionType::Intersecting);
    EXPECT_EQ(intersection3, PlaneIntersectionType::Back);
}

TEST_F(CollisionUtilTest, intersectsPlaneAndBox) {
    const auto box1 = BoundingBox(Float3(-1, 6, -2), Float3(1, 10, 3));
    const auto box2 = BoundingBox(Float3(-1, 5, -2), Float3(1, 10, 3));
    const auto box3 = BoundingBox(Float3(-1, 4, -2), Float3(1, 5, 3));
    const auto box4 = BoundingBox(Float3(-1, -5, -2), Float3(1, 4.9, 3));
    
    const auto intersection1 = collision_util::intersectsPlaneAndBox(plane, box1);
    const auto intersection2 = collision_util::intersectsPlaneAndBox(plane, box2);
    const auto intersection3 = collision_util::intersectsPlaneAndBox(plane, box3);
    const auto intersection4 = collision_util::intersectsPlaneAndBox(plane, box4);
    EXPECT_EQ(intersection1, PlaneIntersectionType::Front);
    EXPECT_EQ(intersection2, PlaneIntersectionType::Intersecting);
    EXPECT_EQ(intersection3, PlaneIntersectionType::Intersecting);
    EXPECT_EQ(intersection4, PlaneIntersectionType::Back);
}

TEST_F(CollisionUtilTest, intersectsPlaneAndSphere) {
    const auto sphere1 = BoundingSphere(Float3(0, 8, 0), 2);
    const auto sphere2 = BoundingSphere(Float3(0, 8, 0), 3);
    const auto sphere3 = BoundingSphere(Float3(0, 3, 0), 2);
    const auto sphere4 = BoundingSphere(Float3(0, 0, 0), 2);
    
    const auto intersection1 = collision_util::intersectsPlaneAndSphere(plane, sphere1);
    const auto intersection2 = collision_util::intersectsPlaneAndSphere(plane, sphere2);
    const auto intersection3 = collision_util::intersectsPlaneAndSphere(plane, sphere3);
    const auto intersection4 = collision_util::intersectsPlaneAndSphere(plane, sphere4);
    EXPECT_EQ(intersection1, PlaneIntersectionType::Front);
    EXPECT_EQ(intersection2, PlaneIntersectionType::Intersecting);
    EXPECT_EQ(intersection3, PlaneIntersectionType::Intersecting);
    EXPECT_EQ(intersection4, PlaneIntersectionType::Back);
}

TEST_F(CollisionUtilTest, intersectsRayAndPlane) {
    const auto ray1 = Ray(Float3(0, 0, 0), Float3(0, 1, 0));
    const auto ray2 = Ray(Float3(0, 0, 0), Float3(0, -1, 0));
    
    const auto distance1 = collision_util::intersectsRayAndPlane(ray1, plane);
    const auto distance2 = collision_util::intersectsRayAndPlane(ray2, plane);
    EXPECT_EQ(distance1, 5);
    EXPECT_EQ(distance2, -1);
}

TEST_F(CollisionUtilTest, intersectsRayAndBox) {
    const auto ray = Ray(Float3(0, 0, 0), Float3(0, 1, 0));
    const auto box1 = BoundingBox(Float3(-1, 3, -1), Float3(2, 8, 3));
    const auto box2 = BoundingBox(Float3(1, 1, 1), Float3(2, 2, 2));
    
    const auto distance1 = collision_util::intersectsRayAndBox(ray, box1);
    const auto distance2 = collision_util::intersectsRayAndBox(ray, box2);
    EXPECT_EQ(distance1, 3);
    EXPECT_EQ(distance2, -1);
}

TEST_F(CollisionUtilTest, intersectsRayAndSphere) {
    const auto ray = Ray(Float3(0, 0, 0), Float3(0, 1, 0));
    const auto sphere1 = BoundingSphere(Float3(0, 4, 0), 3);
    const auto sphere2 = BoundingSphere(Float3(0, -5, 0), 4);
    
    const auto distance1 = collision_util::intersectsRayAndSphere(ray, sphere1);
    const auto distance2 = collision_util::intersectsRayAndSphere(ray, sphere2);
    EXPECT_EQ(distance1, 1);
    EXPECT_EQ(distance2, -1);
}

TEST_F(CollisionUtilTest, intersectsFrustumAndBox) {
    const auto box1 = BoundingBox(Float3(-2, -2, -2), Float3(2, 2, 2));
    const auto flag1 = frustum.intersectsBox(box1);
    EXPECT_EQ(flag1, true);
    
    const auto box2 = BoundingBox(Float3(-32, -2, -2), Float3(-28, 2, 2));
    const auto flag2 = frustum.intersectsBox(box2);
    EXPECT_EQ(flag2, false);
}

TEST_F(CollisionUtilTest, frustumContainsBox) {
    const auto box1 = BoundingBox(Float3(-2, -2, -2), Float3(2, 2, 2));
    const auto box2 = BoundingBox(Float3(-32, -2, -2), Float3(-28, 2, 2));
    const auto box3 = BoundingBox(Float3(-35, -2, -2), Float3(-18, 2, 2));
    
    const auto expected1 = collision_util::frustumContainsBox(frustum, box1);
    const auto expected2 = collision_util::frustumContainsBox(frustum, box2);
    const auto expected3 = collision_util::frustumContainsBox(frustum, box3);
    EXPECT_EQ(expected1, ContainmentType::Contains);
    EXPECT_EQ(expected2, ContainmentType::Disjoint);
    EXPECT_EQ(expected3, ContainmentType::Intersects);
}

TEST_F(CollisionUtilTest, frustumContainsSphere) {
    const auto sphere1 = BoundingSphere(Float3(0, 0, 0), 2);
    const auto sphere2 = BoundingSphere(Float3(-32, -2, -2), 1);
    const auto sphere3 = BoundingSphere(Float3(-32, -2, -2), 15);
    
    const auto expected1 = collision_util::frustumContainsSphere(frustum, sphere1);
    const auto expected2 = collision_util::frustumContainsSphere(frustum, sphere2);
    const auto expected3 = collision_util::frustumContainsSphere(frustum, sphere3);
    EXPECT_EQ(expected1, ContainmentType::Contains);
    EXPECT_EQ(expected2, ContainmentType::Disjoint);
    EXPECT_EQ(expected3, ContainmentType::Intersects);
}
