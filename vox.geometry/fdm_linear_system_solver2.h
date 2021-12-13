// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_FDM_LINEAR_SYSTEM_SOLVER2_H_
#define INCLUDE_JET_FDM_LINEAR_SYSTEM_SOLVER2_H_

#include "fdm_linear_system2.h"

#include <memory>

namespace vox {

//! Abstract base class for 2-D finite difference-type linear system solver.
class FdmLinearSystemSolver2 {
public:
  //! Default constructor.
  FdmLinearSystemSolver2() = default;

  //! Deleted copy constructor.
  FdmLinearSystemSolver2(const FdmLinearSystemSolver2 &) = delete;

  //! Deleted move constructor.
  FdmLinearSystemSolver2(FdmLinearSystemSolver2 &&) noexcept = delete;

  //! Default virtual destructor.
  virtual ~FdmLinearSystemSolver2() = default;

  //! Deleted copy assignment operator.
  FdmLinearSystemSolver2 &operator=(const FdmLinearSystemSolver2 &) = delete;

  //! Deleted move assignment operator.
  FdmLinearSystemSolver2 &operator=(FdmLinearSystemSolver2 &&) noexcept = delete;

  //! Solves the given linear system.
  virtual bool solve(FdmLinearSystem2 *system) = 0;

  //! Solves the given compressed linear system.
  virtual bool solveCompressed(FdmCompressedLinearSystem2 *) { return false; }
};

//! Shared pointer type for the FdmLinearSystemSolver2.
using FdmLinearSystemSolver2Ptr = std::shared_ptr<FdmLinearSystemSolver2>;

} // namespace  vox

#endif // INCLUDE_JET_FDM_LINEAR_SYSTEM_SOLVER2_H_
