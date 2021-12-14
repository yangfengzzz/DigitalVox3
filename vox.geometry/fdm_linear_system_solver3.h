// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_FDM_LINEAR_SYSTEM_SOLVER3_H_
#define INCLUDE_JET_FDM_LINEAR_SYSTEM_SOLVER3_H_

#include "fdm_linear_system3.h"

#include <memory>

namespace vox {
namespace geometry {

//! Abstract base class for 3-D finite difference-type linear system solver.
class FdmLinearSystemSolver3 {
public:
  //! Default constructor.
  FdmLinearSystemSolver3() = default;

  //! Deleted copy constructor.
  FdmLinearSystemSolver3(const FdmLinearSystemSolver3 &) = delete;

  //! Deleted move constructor.
  FdmLinearSystemSolver3(FdmLinearSystemSolver3 &&) noexcept = delete;

  //! Default virtual destructor.
  virtual ~FdmLinearSystemSolver3() = default;

  //! Deleted copy assignment operator.
  FdmLinearSystemSolver3 &operator=(const FdmLinearSystemSolver3 &) = delete;

  //! Deleted move assignment operator.
  FdmLinearSystemSolver3 &operator=(FdmLinearSystemSolver3 &&) noexcept = delete;

  //! Solves the given linear system.
  virtual bool solve(FdmLinearSystem3 *system) = 0;

  //! Solves the given compressed linear system.
  virtual bool solveCompressed(FdmCompressedLinearSystem3 *) { return false; }
};

//! Shared pointer type for the FdmLinearSystemSolver3.
using FdmLinearSystemSolver3Ptr = std::shared_ptr<FdmLinearSystemSolver3>;

} // namespace vox
} // namespace geometry

#endif // INCLUDE_JET_FDM_LINEAR_SYSTEM_SOLVER3_H_
