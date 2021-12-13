// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef SRC_JET_FACTORY_H_
#define SRC_JET_FACTORY_H_

#include "grids/scalar_grid.h"
#include "grids/vector_grid.h"
#include "point_neighbor_searcher.h"

#include <string>

namespace vox {

class Factory {
public:
  static ScalarGrid2Ptr buildScalarGrid2(const std::string &name);

  static ScalarGrid3Ptr buildScalarGrid3(const std::string &name);

  static VectorGrid2Ptr buildVectorGrid2(const std::string &name);

  static VectorGrid3Ptr buildVectorGrid3(const std::string &name);

  static PointNeighborSearcher2Ptr buildPointNeighborSearcher2(const std::string &name);

  static PointNeighborSearcher3Ptr buildPointNeighborSearcher3(const std::string &name);
};

} // namespace vox

#endif // SRC_JET_FACTORY_H_
