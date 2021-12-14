// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_POINTS_TO_IMPLICIT2_H_
#define INCLUDE_JET_POINTS_TO_IMPLICIT2_H_

#include "array_view.h"
#include "grids/scalar_grid.h"
#include "matrix.h"

namespace vox {
namespace geometry {

//! Abstract base class for 2-D points-to-implicit converters.
class PointsToImplicit2 {
public:
  //! Default constructor.
  PointsToImplicit2() = default;

  //! Default copy constructor.
  PointsToImplicit2(const PointsToImplicit2 &) = default;

  //! Default move constructor.
  PointsToImplicit2(PointsToImplicit2 &&) noexcept = default;

  //! Default virtual destructor.
  virtual ~PointsToImplicit2() = default;

  //! Default copy assignment operator.
  PointsToImplicit2 &operator=(const PointsToImplicit2 &) = default;

  //! Default move assignment operator.
  PointsToImplicit2 &operator=(PointsToImplicit2 &&) noexcept = default;

  //! Converts the given points to implicit surface scalar field.
  virtual void convert(const ConstArrayView1<Vector2D> &points, ScalarGrid2 *output) const = 0;
};

//! Shared pointer for the PointsToImplicit2 type.
using PointsToImplicit2Ptr = std::shared_ptr<PointsToImplicit2>;

} // namespace vox
} // namespace geometry

#endif // INCLUDE_JET_POINTS_TO_IMPLICIT2_H_
