// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_FDM_MG_LINEAR_SYSTEM3_INL_H_
#define INCLUDE_JET_FDM_MG_LINEAR_SYSTEM3_INL_H_

#include "fdm_mg_linear_system3.h"

namespace vox {
namespace geometry {

template <typename T>
void FdmMgUtils3::resizeArrayWithCoarsest(const Vector3UZ &coarsestResolution, size_t numberOfLevels,
                                          std::vector<Array3<T>> *levels) {
  numberOfLevels = std::max(numberOfLevels, kOneSize);

  levels->resize(numberOfLevels);

  // Level 0 is the finest level, thus takes coarsestResolution ^
  // numberOfLevels.
  // Level numberOfLevels - 1 is the coarsest, taking coarsestResolution.
  Vector3UZ res = coarsestResolution;
  for (size_t level = 0; level < numberOfLevels; ++level) {
    (*levels)[numberOfLevels - level - 1].resize(res);
    res.x = res.x << 1;
    res.y = res.y << 1;
    res.z = res.z << 1;
  }
}

template <typename T>
void FdmMgUtils3::resizeArrayWithFinest(const Vector3UZ &finestResolution, size_t maxNumberOfLevels,
                                        std::vector<Array3<T>> *levels) {
  Vector3UZ res = finestResolution;
  size_t i = 1;
  for (; i < maxNumberOfLevels; ++i) {
    if (res.x % 2 == 0 && res.y % 2 == 0 && res.z % 2 == 0) {
      res.x = res.x >> 1;
      res.y = res.y >> 1;
      res.z = res.z >> 1;
    } else {
      break;
    }
  }
  resizeArrayWithCoarsest(res, i, levels);
}

} // namespace vox
} // namespace geometry

#endif // INCLUDE_JET_FDM_MG_LINEAR_SYSTEM3_INL_H_
