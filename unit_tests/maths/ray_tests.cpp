//
//  ray_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/26.
//

#include "maths/ray.h"
#include "maths/plane.h"
#include "maths/bounding_sphere.h"
#include "maths/bounding_box.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using namespace ozz::math;

TEST(Ray, ray_plane) {
    const auto ray = Ray(Float3(0, 0, 0), Float3(0, 1, 0));
    const auto plane = Plane(Float3(0, 1, 0), -3);
    
    EXPECT_FLOAT_EQ(ray.intersectPlane(plane), -plane.distance);
}

TEST(Ray, ray_sphere) {
    const auto ray = Ray(Float3(0, 0, 0), Float3(0, 1, 0));
    const auto sphere = BoundingSphere(Float3(0, 5, 0), 1);
    
    EXPECT_FLOAT_EQ(ray.intersectSphere(sphere), 4);
}

TEST(Ray, ray_box) {
    const auto ray = Ray(Float3(0, 0, 0), Float3(0, 1, 0));
    const auto box = BoundingBox::fromCenterAndExtent(Float3(0, 20, 0), Float3(5, 5, 5));
    
    EXPECT_FLOAT_EQ(ray.intersectBox(box), 15);
}

TEST(Ray, ray_getPoint) {
    const auto ray = Ray(Float3(0, 0, 0), Float3(0, 1, 0));
    const auto out = ray.getPoint(10);
    
    EXPECT_FLOAT3_EQ(out, 0, 10, 0);
}
