// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "common.h"

#include "point_neighbor_searcher.h"

namespace vox {
namespace geometry {

template <size_t N> void PointNeighborSearcher<N>::build(const ConstArrayView1<Vector<double, N>> &points) {
  build(points, kMaxD);
}

template class PointNeighborSearcher<2>;

template class PointNeighborSearcher<3>;

} // namespace vox
} // namespace geometry
