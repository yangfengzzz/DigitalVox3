// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "../vox.geometry/array.h"
#include "../vox.geometry/bounding_box.h"
#include "../vox.geometry/point_generators/triangle_point_generator.h"
#include "../vox.geometry/point_searchers/point_hash_grid_searcher.h"
#include "../vox.geometry/point_searchers/point_hash_grid_utils.h"
#include "../vox.geometry/point_searchers/point_parallel_hash_grid_searcher.h"
#include <gtest/gtest.h>

using namespace vox;

TEST(PointHashGridSearcher2, ForEachNearbyPoint) {
  Array1<Vector2D> points = {Vector2D(1, 3), Vector2D(2, 5), Vector2D(-1, 3)};

  PointHashGridSearcher2 searcher({4, 4}, 2.0 * std::sqrt(10));
  searcher.build(points);

  searcher.forEachNearbyPoint(Vector2D(0, 0), std::sqrt(10.0), [&points](size_t i, const Vector2D &pt) {
    EXPECT_TRUE(i == 0 || i == 2);

    if (i == 0) {
      EXPECT_EQ(points[0], pt);
    } else if (i == 2) {
      EXPECT_EQ(points[2], pt);
    }
  });
}

TEST(PointHashGridSearcher2, ForEachNearbyPointEmpty) {
  Array1<Vector2D> points;

  PointHashGridSearcher2 searcher({4, 4}, 2.0 * std::sqrt(10));
  searcher.build(points);

  searcher.forEachNearbyPoint(Vector2D(0, 0), std::sqrt(10.0), [](size_t, const Vector2D &) {});
}

TEST(PointHashGridSearcher2, HasEachNearByPoint) {
  const Array1<Vector2D> points = {Vector2D(1, 1), Vector2D(3, 4), Vector2D(4, 5)};

  PointHashGridSearcher2 searcher(Vector2UZ{4, 4}, std::sqrt(10));
  searcher.build(points);

  const bool result = searcher.hasNearbyPoint(Vector2D{}, std::sqrt(15.0));

  EXPECT_TRUE(result);
}

TEST(PointHashGridSearcher2, Build) {
  const Array1<Vector2D> points = {Vector2D(3, 4), Vector2D(1, 5), Vector2D(-3, 0)};

  PointHashGridSearcher2 searcher(Vector2UZ{4, 4}, std::sqrt(10));
  searcher.build(points);

  EXPECT_EQ(Vector2Z(0, 1), PointHashGridUtils2::getBucketIndex(Vector2D{3, 4}, std::sqrt(10)));
  EXPECT_EQ(Vector2Z(0, 1), PointHashGridUtils2::getBucketIndex(Vector2D{1, 5}, std::sqrt(10)));
  EXPECT_EQ(Vector2Z(-1, 0), PointHashGridUtils2::getBucketIndex(Vector2D{-3, 0}, std::sqrt(10)));

  EXPECT_EQ(4, PointHashGridUtils2::getHashKeyFromBucketIndex(Vector2Z{0, 1}, Vector2Z{4, 4}));
  EXPECT_EQ(8, PointHashGridUtils2::getHashKeyFromBucketIndex(Vector2Z{0, 2}, Vector2Z{4, 4}));
  EXPECT_EQ(3, PointHashGridUtils2::getHashKeyFromBucketIndex(Vector2Z{-1, 0}, Vector2Z{4, 4}));
}
