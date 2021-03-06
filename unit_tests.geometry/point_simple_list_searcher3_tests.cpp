// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include <gtest/gtest.h>

#include "../vox.geometry/array.h"
#include "../vox.geometry/point_searchers/point_simple_list_searcher.h"

using namespace vox;
using namespace geometry;

TEST(PointSimpleListSearcher3, ForEachNearbyPoint) {
  Array1<Vector3D> points = {Vector3D(0, 1, 3), Vector3D(2, 5, 4), Vector3D(-1, 3, 0)};

  PointSimpleListSearcher3 searcher;
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

TEST(PointSimpleListSearcher3, CopyConstructor) {
  Array1<Vector3D> points = {Vector3D(0, 1, 3), Vector3D(2, 5, 4), Vector3D(-1, 3, 0)};

  PointSimpleListSearcher3 searcher;
  searcher.build(points);

  PointSimpleListSearcher3 searcher2(searcher);
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

TEST(PointSimpleListSearcher3, Serialization) {
  Array1<Vector3D> points = {Vector3D(0, 1, 3), Vector3D(2, 5, 4), Vector3D(-1, 3, 0)};

  PointSimpleListSearcher3 searcher;
  searcher.build(points);

  std::vector<uint8_t> buffer;
  searcher.serialize(&buffer);

  PointSimpleListSearcher3 searcher2;
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
