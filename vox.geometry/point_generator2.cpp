// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "point_generator2.h"
#include "common.h"

namespace vox {
namespace geometry {

void PointGenerator2::generate(const BoundingBox2D &boundingBox, double spacing, Array1<Vector2D> *points) const {
  forEachPoint(boundingBox, spacing, [&points](const Vector2D &point) {
    points->append(point);
    return true;
  });
}

} // namespace vox
} // namespace geometry
