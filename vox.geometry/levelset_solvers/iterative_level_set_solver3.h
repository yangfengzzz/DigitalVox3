// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_ITERATIVE_LEVEL_SET_SOLVER3_H_
#define INCLUDE_JET_ITERATIVE_LEVEL_SET_SOLVER3_H_

#include "../level_set_solver3.h"

namespace vox {
namespace geometry {

//!
//! \brief Abstract base class for 3-D PDE-based iterative level set solver.
//!
//! This class provides infrastructure for 3-D PDE-based iterative level set
//! solver. Internally, the class implements upwind-style wave propagation and
//! the inheriting classes must provide a way to compute the derivatives for
//! given grid points.
//!
//! \see Osher, Stanley, and Ronald Fedkiw. Level set methods and dynamic
//!     implicit surfaces. Vol. 153. Springer Science & Business Media, 2006.
//!
class IterativeLevelSetSolver3 : public LevelSetSolver3 {
public:
  //! Default constructor.
  IterativeLevelSetSolver3() = default;

  //! Deleted copy constructor.
  IterativeLevelSetSolver3(const IterativeLevelSetSolver3 &) = delete;

  //! Deleted move constructor.
  IterativeLevelSetSolver3(IterativeLevelSetSolver3 &&) noexcept = delete;

  //! Default virtual destructor.
  ~IterativeLevelSetSolver3() override = default;

  //! Deleted copy assignment operator.
  IterativeLevelSetSolver3 &operator=(const IterativeLevelSetSolver3 &) = delete;

  //! Deleted move assignment operator.
  IterativeLevelSetSolver3 &operator=(IterativeLevelSetSolver3 &&) noexcept = delete;

  //!
  //! Reinitialize given scalar field to signed-distance field.
  //!
  //! \param inputSdf Input signed-distance field which can be distorted.
  //! \param maxDistance Max range of reinitialization.
  //! \param outputSdf Output signed-distance field.
  //!
  void reinitialize(const ScalarGrid3 &inputSdf, double maxDistance, ScalarGrid3 *outputSdf) override;

  //!
  //! Extrapolates given scalar field from negative to positive SDF region.
  //!
  //! \param input Input scalar field to be extrapolated.
  //! \param sdf Reference signed-distance field.
  //! \param maxDistance Max range of extrapolation.
  //! \param output Output scalar field.
  //!
  void extrapolate(const ScalarGrid3 &input, const ScalarField3 &sdf, double maxDistance, ScalarGrid3 *output) override;

  //!
  //! Extrapolates given collocated vector field from negative to positive SDF
  //! region.
  //!
  //! \param input Input collocated vector field to be extrapolated.
  //! \param sdf Reference signed-distance field.
  //! \param maxDistance Max range of extrapolation.
  //! \param output Output collocated vector field.
  //!
  void extrapolate(const CollocatedVectorGrid3 &input, const ScalarField3 &sdf, double maxDistance,
                   CollocatedVectorGrid3 *output) override;

  //!
  //! Extrapolates given face-centered vector field from negative to positive
  //! SDF region.
  //!
  //! \param input Input face-centered field to be extrapolated.
  //! \param sdf Reference signed-distance field.
  //! \param maxDistance Max range of extrapolation.
  //! \param output Output face-centered vector field.
  //!
  void extrapolate(const FaceCenteredGrid3 &input, const ScalarField3 &sdf, double maxDistance,
                   FaceCenteredGrid3 *output) override;

  //! Returns the maximum CFL limit.
  [[nodiscard]] double maxCfl() const;

  //!
  //! \brief Sets the maximum CFL limit.
  //!
  //! This function sets the maximum CFL limit for the internal upwind-style
  //! PDE calculation. The negative input will be clamped to 0.
  //!
  void setMaxCfl(double newMaxCfl);

protected:
  //! Computes the derivatives for given grid point.
  virtual void getDerivatives(ConstArrayView3<double> grid, const Vector3D &gridSpacing, size_t i, size_t j, size_t k,
                              std::array<double, 2> *dx, std::array<double, 2> *dy,
                              std::array<double, 2> *dz) const = 0;

private:
  double _maxCfl = 0.5;

  void extrapolate(const ConstArrayView3<double> &input, const ConstArrayView3<double> &sdf,
                   const Vector3D &gridSpacing, double maxDistance, ArrayView3<double> output);

  static unsigned int distanceToNumberOfIterations(double distance, double dtau);

  static double sign(const ConstArrayView3<double> &sdf, const Vector3D &gridSpacing, size_t i, size_t j, size_t k);

  [[nodiscard]] double pseudoTimeStep(const ConstArrayView3<double> &sdf, const Vector3D &gridSpacing) const;
};

using IterativeLevelSetSolver3Ptr = std::shared_ptr<IterativeLevelSetSolver3>;

} // namespace vox
} // namespace geometry

#endif // INCLUDE_JET_ITERATIVE_LEVEL_SET_SOLVER3_H_
