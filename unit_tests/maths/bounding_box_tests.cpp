//
//  bounding_box_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/26.
//

#include "maths/bounding_box.h"
#include "maths/bounding_sphere.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using vox::math::BoundingBox;
using vox::math::Float3;
using vox::math::BoundingSphere;
using vox::math::Matrix;

TEST(BoundingBox, Constructor) {
    // Create a same box by different param.
    const auto box1 = BoundingBox::fromCenterAndExtent(Float3(0, 0, 0), Float3(1, 1, 1));
    
    const Float3 points[] = {
        Float3(0, 0, 0),
        Float3(-1, 0, 0),
        Float3(1, 0, 0),
        Float3(0, 1, 0),
        Float3(0, 1, 1),
        Float3(1, 0, 1),
        Float3(0, 0.5, 0.5),
        Float3(0, -0.5, 0.5),
        Float3(0, -1, 0.5),
        Float3(0, 0, -1)
    };
    const auto box2 = BoundingBox(points, sizeof(Float3), 10);
    
    const auto sphere = BoundingSphere(Float3(0, 0, 0), 1);
    const auto box3 = BoundingBox::fromSphere(sphere);
    
    const auto &min1 = box1.min;
    const auto &max1 = box1.max;
    const auto &min2 = box2.min;
    const auto &max2 = box2.max;
    const auto &min3 = box3.min;
    const auto &max3 = box3.max;
    
    EXPECT_FLOAT3_EQ(min1, min2.x, min2.y, min2.z);
    EXPECT_FLOAT3_EQ(max1, max2.x, max2.y, max2.z);
    EXPECT_FLOAT3_EQ(min1, min3.x, min3.y, min3.z);
    EXPECT_FLOAT3_EQ(max1, max3.x, max3.y, max3.z);
    EXPECT_FLOAT3_EQ(min2, min3.x, min3.y, min3.z);
    EXPECT_FLOAT3_EQ(max2, max3.x, max3.y, max3.z);
}

TEST(BoundingBox, transform) {
    auto box = BoundingBox(Float3(-1, -1, -1), Float3(1, 1, 1));
    const auto matrix = Matrix(2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2, 0, 1, 0.5, -1, 1);
    const auto newBox = transform(box, matrix);
    box = transform(box, matrix);
    
    const auto newMin = Float3(-1, -1.5, -3);
    const auto newMax = Float3(3, 2.5, 1);
    EXPECT_FLOAT3_EQ(newBox.min, newMin.x, newMin.y, newMin.z);
    EXPECT_FLOAT3_EQ(newBox.max, newMax.x, newMax.y, newMax.z);
    EXPECT_FLOAT3_EQ(box.min, newMin.x, newMin.y, newMin.z);
    EXPECT_FLOAT3_EQ(box.max, newMax.x, newMax.y, newMax.z);
}

TEST(BoundingBox, merge) {
    const auto box1 = BoundingBox(Float3(-1, -1, -1), Float3(2, 2, 2));
    const auto box2 = BoundingBox(Float3(-2, -0.5, -2), Float3(3, 0, 3));
    const auto box = Merge(box1, box2);
    EXPECT_FLOAT3_EQ(box.min, -2, -1, -2);
    EXPECT_FLOAT3_EQ(box.max, 3, 2, 3);
}

TEST(BoundingBox, getCenter) {
    const auto box = BoundingBox(Float3(-1, -1, -1), Float3(3, 3, 3));
    const auto center = box.getCenter();
    EXPECT_FLOAT3_EQ(center, 1, 1, 1);
}

TEST(BoundingBox, getExtent) {
    const auto box = BoundingBox(Float3(-1, -1, -1), Float3(3, 3, 3));
    const auto extent = box.getExtent();
    EXPECT_FLOAT3_EQ(extent, 2, 2, 2);
}

TEST(BoundingBox, getCorners) {
    const auto min = Float3(-1, -1, -1);
    const auto max = Float3(3, 3, 3);
    const auto &minX = min.x;
    const auto &minY = min.y;
    const auto &minZ = min.z;
    const auto &maxX = max.x;
    const auto &maxY = max.y;
    const auto &maxZ = max.z;
    const Float3 expectedCorners[] = {
        Float3(minX, maxY, maxZ),
        Float3(maxX, maxY, maxZ),
        Float3(maxX, minY, maxZ),
        Float3(minX, minY, maxZ),
        Float3(minX, maxY, minZ),
        Float3(maxX, maxY, minZ),
        Float3(maxX, minY, minZ),
        Float3(minX, minY, minZ),
    };
    
    const auto box = BoundingBox(min, max);
    const auto corners = box.getCorners();
    for (int i = 0; i < 8; ++i) {
        EXPECT_FLOAT3_EQ(corners[i], expectedCorners[i].x, expectedCorners[i].y, expectedCorners[i].z);
    }
}

TEST(BoundingSphere, Constructor) {
    // Create a same sphere by different param.
    const Float3 points[] = {
        Float3(0, 0, 0),
        Float3(-1, 0, 0),
        Float3(0, 0, 0),
        Float3(0, 1, 0),
        Float3(1, 1, 1),
        Float3(0, 0, 1),
        Float3(-1, -0.5, -0.5),
        Float3(0, -0.5, -0.5),
        Float3(1, 0, -1),
        Float3(0, -1, 0)
    };
    const auto sphere1 = BoundingSphere(points, sizeof(Float3), 10);
    
    const auto box = BoundingBox(Float3(-1, -1, -1), Float3(1, 1, 1));
    const auto sphere2 = BoundingSphere::fromBox(box);
    
    const auto &center1 = sphere1.center;
    const auto &radius1 = sphere1.radius;
    const auto &center2 = sphere2.center;
    const auto &radius2 = sphere2.radius;
    
    EXPECT_FLOAT3_EQ(center1, center2.x, center2.y, center2.z);
    EXPECT_FLOAT_EQ(radius1, radius2);
}
