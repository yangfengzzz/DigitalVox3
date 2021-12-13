// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "../vox.geometry/array.h"
#include "../vox.geometry/point_generators/bcc_lattice_point_generator.h"
#include "../vox.geometry/point_searchers/point_hash_grid_searcher.h"
#include "../vox.geometry/point_searchers/point_hash_grid_utils.h"
#include "../vox.geometry/point_searchers/point_parallel_hash_grid_searcher.h"
#include <gtest/gtest.h>
#include <vector>

using namespace vox;

TEST(PointParallelHashGridSearcher3, ForEachNearbyPoint) {
  Array1<Vector3D> points = {Vector3D(0, 1, 3), Vector3D(2, 5, 4), Vector3D(-1, 3, 0)};

  PointParallelHashGridSearcher3 searcher({4, 4, 4}, std::sqrt(10));
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

TEST(PointParallelHashGridSearcher3, ForEachNearbyPointEmpty) {
  Array1<Vector3D> points;

  PointParallelHashGridSearcher3 searcher({4, 4, 4}, std::sqrt(10));
  searcher.build(points);

  searcher.forEachNearbyPoint(Vector3D(0, 0, 0), std::sqrt(10.0), [](size_t, const Vector3D &) {});
}

TEST(PointParallelHashGridSearcher3, CopyConstructor) {
  Array1<Vector3D> points = {Vector3D(0, 1, 3), Vector3D(2, 5, 4), Vector3D(-1, 3, 0)};

  PointParallelHashGridSearcher3 searcher({4, 4, 4}, std::sqrt(10));
  searcher.build(points);

  PointParallelHashGridSearcher3 searcher2(searcher);
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

TEST(PointParallelHashGridSearcher3, Serialization) {
  Array1<Vector3D> points = {Vector3D(0, 1, 3), Vector3D(2, 5, 4), Vector3D(-1, 3, 0)};

  PointParallelHashGridSearcher3 searcher({4, 4, 4}, std::sqrt(10));
  searcher.build(points);

  std::vector<uint8_t> buffer;
  searcher.serialize(&buffer);

  PointParallelHashGridSearcher3 searcher2({1, 1, 1}, 1.0);
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

TEST(PointParallelHashGridSearcher3, Build) {
  Array1<Vector3D> points;
  BccLatticePointGenerator pointsGenerator;
  BoundingBox3D bbox{Vector3D{0, 0, 0}, Vector3D{1, 1, 1}};
  double spacing = 0.1;

  pointsGenerator.generate(bbox, spacing, &points);

  PointHashGridSearcher3 pointSearcher{Vector3UZ{4, 4, 4}, 0.18};
  pointSearcher.build(points);

  Array3<size_t> grid(4, 4, 4);

  forEachIndex(grid.size(), [&](size_t i, size_t j, size_t k) {
    const size_t key = PointHashGridUtils3::getHashKeyFromBucketIndex(
        Vector3Z{static_cast<ssize_t>(i), static_cast<ssize_t>(j), static_cast<ssize_t>(k)}, Vector3Z{4, 4, 4});
    const size_t value = pointSearcher.buckets()[key].length();
    grid(i, j, k) = value;
  });

  PointParallelHashGridSearcher3 parallelSearcher{Vector3UZ{4, 4, 4}, 0.18};
  parallelSearcher.build(points);

  forEachIndex(grid.size(), [&](size_t i, size_t j, size_t k) {
    const size_t key = PointHashGridUtils3::getHashKeyFromBucketIndex(
        Vector3Z{static_cast<ssize_t>(i), static_cast<ssize_t>(j), static_cast<ssize_t>(k)}, Vector3Z{4, 4, 4});
    const size_t start = parallelSearcher.startIndexTable()[key];
    const size_t end = parallelSearcher.endIndexTable()[key];
    const size_t value = end - start;
    EXPECT_EQ(grid(i, j, k), value);
  });
}
