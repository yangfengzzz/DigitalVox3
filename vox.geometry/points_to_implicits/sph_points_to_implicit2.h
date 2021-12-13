// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_SPH_POINTS_TO_IMPLICIT2_H_
#define INCLUDE_JET_SPH_POINTS_TO_IMPLICIT2_H_

#include "../points_to_implicit2.h"

namespace vox {

//!
//! \brief 2-D points-to-implicit converter based on standard SPH kernel.
//!
//! \see Müller, Matthias, David Charypar, and Markus Gross.
//!      "Particle-based fluid simulation for interactive applications."
//!      Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
//!      animation. Eurographics Association, 2003.
//!
class SphPointsToImplicit2 final : public PointsToImplicit2 {
public:
  //! Constructs the converter with given kernel radius and cut-off density.
  explicit SphPointsToImplicit2(double kernelRadius = 1.0, double cutOffDensity = 0.5, bool isOutputSdf = true);

  //! Converts the given points to implicit surface scalar field.
  void convert(const ConstArrayView1<Vector2D> &points, ScalarGrid2 *output) const override;

private:
  double _kernelRadius = 1.0;
  double _cutOffDensity = 0.5;
  bool _isOutputSdf = true;
};

//! Shared pointer type for SphPointsToImplicit2 class.
using SphPointsToImplicit2Ptr = std::shared_ptr<SphPointsToImplicit2>;

} // namespace  vox

#endif // INCLUDE_JET_SPH_POINTS_TO_IMPLICIT2_H_
