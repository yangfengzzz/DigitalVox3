// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "../vox.geometry/array.h"
#include "../vox.geometry/array_utils.h"
#include "../vox.geometry/bounding_box.h"
#include "../vox.geometry/point_generators/bcc_lattice_point_generator.h"
#include "../vox.geometry/point_searchers/point_hash_grid_searcher.h"
#include "../vox.geometry/point_searchers/point_hash_grid_utils.h"
#include "../vox.geometry/point_searchers/point_parallel_hash_grid_searcher.h"

#include <gtest/gtest.h>

using namespace vox;
using namespace geometry;

TEST(PointHashGridSearcher3, ForEachNearbyPoint) {
  Array1<Vector3D> points = {Vector3D(0, 1, 3), Vector3D(2, 5, 4), Vector3D(-1, 3, 0)};

  PointHashGridSearcher3 searcher(Vector3UZ(4, 4, 4), 2.0 * std::sqrt(10));
  searcher.build(points);

  int cnt = 0;
  searcher.forEachNearbyPoint(Vector3D(0, 0, 0), std::sqrt(10.0), [&](size_t i, const Vector3D &pt) {
    EXPECT_TRUE(i == 0 || i == 2);

    if (i == 0) {
      EXPECT_EQ(points[0], pt);
    } else if (i == 2) {
      EXPECT_EQ(points[2], pt);
    }

    ++cnt;
  });
  EXPECT_EQ(2, cnt);
}

TEST(PointHashGridSearcher3, ForEachNearbyPointEmpty) {
  Array1<Vector3D> points;

  PointHashGridSearcher3 searcher(Vector3UZ(4, 4, 4), 2.0 * std::sqrt(10));
  searcher.build(points);

  searcher.forEachNearbyPoint(Vector3D(0, 0, 0), std::sqrt(10.0), [](size_t, const Vector3D &) {});
}

TEST(PointHashGridSearcher3, HasEachNearByPoint) {
  const Array1<Vector3D> points = {Vector3D{1, 1, 1}, Vector3D{3, 444, 1}, Vector3D{4, 15, 111}};

  PointHashGridSearcher3 searcher(Vector3UZ(4, 4, 4), std::sqrt(10));
  searcher.build(points);

  const bool result = searcher.hasNearbyPoint(Vector3D{}, std::sqrt(15.0));

  EXPECT_TRUE(result);
}

TEST(PointHashGridSearcher3, Build) {
  Array1<Vector3D> points = {Vector3D{3, 4, 111}, Vector3D{111, 5, 1}, Vector3D{-311, 1123, 0}};

  PointHashGridSearcher3 searcher(Vector3UZ{4, 4, 4}, std::sqrt(9));
  searcher.build(points);

  EXPECT_EQ(Vector3Z(1, 1, 37), PointHashGridUtils3::getBucketIndex(points[0], std::sqrt(9)));
  EXPECT_EQ(Vector3Z(37, 1, 0), PointHashGridUtils3::getBucketIndex(points[1], std::sqrt(9)));
  EXPECT_EQ(Vector3Z(-104, 374, 0), PointHashGridUtils3::getBucketIndex(points[2], std::sqrt(9)));

  EXPECT_EQ(21, PointHashGridUtils3::getHashKeyFromBucketIndex(Vector3Z{1, 1, 37}, Vector3Z{4, 4, 4}));
  EXPECT_EQ(5, PointHashGridUtils3::getHashKeyFromBucketIndex(Vector3Z{37, 1, 0}, Vector3Z{4, 4, 4}));
  EXPECT_EQ(8, PointHashGridUtils3::getHashKeyFromBucketIndex(Vector3Z{-104, 374, 0}, Vector3Z{4, 4, 4}));
}

TEST(PointHashGridSearcher3, CopyConstructor) {
  Array1<Vector3D> points = {Vector3D(0, 1, 3), Vector3D(2, 5, 4), Vector3D(-1, 3, 0)};

  PointHashGridSearcher3 searcher(Vector3UZ(4, 4, 4), 2.0 * std::sqrt(10));
  searcher.build(points);

  PointHashGridSearcher3 searcher2(searcher);
  int cnt = 0;
  searcher2.forEachNearbyPoint(Vector3D(0, 0, 0), std::sqrt(10.0), [&](size_t i, const Vector3D &pt) {
    EXPECT_TRUE(i == 0 || i == 2);

    if (i == 0) {
      EXPECT_EQ(points[0], pt);
    } else if (i == 2) {
      EXPECT_EQ(points[2], pt);
    }

    ++cnt;
  });
  EXPECT_EQ(2, cnt);
}

TEST(PointHashGridSearcher3, Serialize) {
  Array1<Vector3D> points = {Vector3D(0, 1, 3), Vector3D(2, 5, 4), Vector3D(-1, 3, 0)};

  PointHashGridSearcher3 searcher(Vector3UZ(4, 4, 4), 2.0 * std::sqrt(10));
  searcher.build(points);

  std::vector<uint8_t> buffer;
  searcher.serialize(&buffer);

  PointHashGridSearcher3 searcher2(Vector3UZ(1, 1, 1), 1.0);
  searcher2.deserialize(buffer);

  int cnt = 0;
  searcher2.forEachNearbyPoint(Vector3D(0, 0, 0), std::sqrt(10.0), [&](size_t i, const Vector3D &pt) {
    EXPECT_TRUE(i == 0 || i == 2);

    if (i == 0) {
      EXPECT_EQ(points[0], pt);
    } else if (i == 2) {
      EXPECT_EQ(points[2], pt);
    }

    ++cnt;
  });
  EXPECT_EQ(2, cnt);
}
