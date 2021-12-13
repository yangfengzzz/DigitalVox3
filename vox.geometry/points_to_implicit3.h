// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_POINTS_TO_IMPLICIT3_H_
#define INCLUDE_JET_POINTS_TO_IMPLICIT3_H_

#include "array_view.h"
#include "grids/scalar_grid.h"
#include "matrix.h"

namespace vox {

//! Abstract base class for 3-D points-to-implicit converters.
class PointsToImplicit3 {
public:
  //! Default constructor.
  PointsToImplicit3() = default;

  //! Default copy constructor.
  PointsToImplicit3(const PointsToImplicit3 &) = default;

  //! Default move constructor.
  PointsToImplicit3(PointsToImplicit3 &&) noexcept = default;

  //! Default virtual destructor.
  virtual ~PointsToImplicit3() = default;

  //! Default copy assignment operator.
  PointsToImplicit3 &operator=(const PointsToImplicit3 &) = default;

  //! Default move assignment operator.
  PointsToImplicit3 &operator=(PointsToImplicit3 &&) noexcept = default;

  //! Converts the given points to implicit surface scalar field.
  virtual void convert(const ConstArrayView1<Vector3D> &points, ScalarGrid3 *output) const = 0;
};

//! Shared pointer for the PointsToImplicit3 type.
using PointsToImplicit3Ptr = std::shared_ptr<PointsToImplicit3>;

} // namespace  vox

#endif // INCLUDE_JET_POINTS_TO_IMPLICIT3_H_
