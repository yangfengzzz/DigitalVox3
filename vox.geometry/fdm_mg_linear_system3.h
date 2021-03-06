// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_FDM_MG_LINEAR_SYSTEM3_H_
#define INCLUDE_JET_FDM_MG_LINEAR_SYSTEM3_H_

#include "fdm_linear_system3.h"
#include "grids/face_centered_grid.h"
#include "mg.h"

namespace vox {
namespace geometry {

//! Multigrid-style 3-D FDM matrix.
using FdmMgMatrix3 = MgMatrix<FdmBlas3>;

//! Multigrid-style 3-D FDM vector.
using FdmMgVector3 = MgVector<FdmBlas3>;

//! Multigrid-style 3-D linear system.
struct FdmMgLinearSystem3 {
  //! The system matrix.
  FdmMgMatrix3 A;

  //! The solution vector.
  FdmMgVector3 x;

  //! The RHS vector.
  FdmMgVector3 b;

  //! Clears the linear system.
  void clear();

  //! Returns the number of multigrid levels.
  [[nodiscard]] size_t numberOfLevels() const;

  //! Resizes the system with the coarsest resolution and number of levels.
  void resizeWithCoarsest(const Vector3UZ &coarsestResolution, size_t numberOfLevels);

  //!
  //! \brief Resizes the system with the finest resolution and max number of
  //! levels.
  //!
  //! This function resizes the system with multiple levels until the
  //! resolution is divisible with 2^(level-1).
  //!
  //! \param finestResolution - The finest grid resolution.
  //! \param maxNumberOfLevels - Maximum number of multigrid levels.
  //!
  void resizeWithFinest(const Vector3UZ &finestResolution, size_t maxNumberOfLevels);
};

//! Multigrid utilities for 2-D FDM system.
class FdmMgUtils3 {
public:
  //! Restricts given finer grid to the coarser grid.
  static void restrict(const FdmVector3 &finer, FdmVector3 *coarser);

  //! Corrects given coarser grid to the finer grid.
  static void correct(const FdmVector3 &coarser, FdmVector3 *finer);

  //! Resizes the array with the coarsest resolution and number of levels.
  template <typename T>
  static void resizeArrayWithCoarsest(const Vector3UZ &coarsestResolution, size_t numberOfLevels,
                                      std::vector<Array3<T>> *levels);

  //!
  //! \brief Resizes the array with the finest resolution and max number of
  //! levels.
  //!
  //! This function resizes the system with multiple levels until the
  //! resolution is divisible with 2^(level-1).
  //!
  //! \param finestResolution - The finest grid resolution.
  //! \param maxNumberOfLevels - Maximum number of multigrid levels.
  //!
  template <typename T>
  static void resizeArrayWithFinest(const Vector3UZ &finestResolution, size_t maxNumberOfLevels,
                                    std::vector<Array3<T>> *levels);
};

} // namespace vox
} // namespace geometry

#include "fdm_mg_linear_system3-inl.h"

#endif // INCLUDE_JET_FDM_MG_LINEAR_SYSTEM3_H_
