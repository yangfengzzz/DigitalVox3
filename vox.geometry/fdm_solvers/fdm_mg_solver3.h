// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_FDM_MG_SOLVER3_H_
#define INCLUDE_JET_FDM_MG_SOLVER3_H_

#include "../fdm_linear_system_solver3.h"
#include "../fdm_mg_linear_system3.h"
#include "../mg.h"

namespace vox {

//! \brief 3-D finite difference-type linear system solver using Multigrid.
class FdmMgSolver3 : public FdmLinearSystemSolver3 {
public:
  //! Constructs the solver with given parameters.
  explicit FdmMgSolver3(size_t maxNumberOfLevels, unsigned int numberOfRestrictionIter = 5,
                        unsigned int numberOfCorrectionIter = 5, unsigned int numberOfCoarsestIter = 20,
                        unsigned int numberOfFinalIter = 20, double maxTolerance = 1e-9, double sorFactor = 1.5,
                        bool useRedBlackOrdering = false);

  //! Returns the Multigrid parameters.
  [[nodiscard]] const MgParameters<FdmBlas3> &params() const;

  //! Returns the SOR (Successive Over Relaxation) factor.
  [[nodiscard]] double sorFactor() const;

  //! Returns true if red-black ordering is enabled.
  [[nodiscard]] bool useRedBlackOrdering() const;

  //! No-op. Multigrid-type solvers do not solve FdmLinearSystem3.
  bool solve(FdmLinearSystem3 *system) final;

  //! Solves Multigrid linear system.
  virtual bool solve(FdmMgLinearSystem3 *system);

private:
  MgParameters<FdmBlas3> _mgParams;
  double _sorFactor;
  bool _useRedBlackOrdering;
};

//! Shared pointer type for the FdmMgSolver3.
using FdmMgSolver3Ptr = std::shared_ptr<FdmMgSolver3>;

} // namespace  vox

#endif // INCLUDE_JET_FDM_MG_SOLVER3_H_
