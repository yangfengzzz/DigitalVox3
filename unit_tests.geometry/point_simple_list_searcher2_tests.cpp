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

TEST(PointSimpleListSearcher2, ForEachNearbyPoint) {
  Array1<Vector2D> points = {Vector2D(1, 3), Vector2D(2, 5), Vector2D(-1, 3)};

  PointSimpleListSearcher2 searcher;
  searcher.build(points);

  searcher.forEachNearbyPoint(Vector2D(0, 0), std::sqrt(10.0), [&](size_t i, const Vector2D &pt) {
    EXPECT_TRUE(i == 0 || i == 2);

    if (i == 0) {
      EXPECT_EQ(points[0], pt);
    } else if (i == 2) {
      EXPECT_EQ(points[2], pt);
    }
  });
}
