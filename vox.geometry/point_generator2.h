// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_POINT_GENERATOR2_H_
#define INCLUDE_JET_POINT_GENERATOR2_H_

#include "array.h"
#include "bounding_box.h"

#include <functional>
#include <memory>

namespace vox {
namespace geometry {

//!
//! \brief Abstract base class for 2-D point generator.
//!
//! This class provides interface for 2-D point generator. For given bounding
//! box and point spacing, the inherited classes generates points with specified
//! pattern.
//!
class PointGenerator2 {
public:
  //! Default constructor.
  PointGenerator2() = default;

  //! Default copy constructor.
  PointGenerator2(const PointGenerator2 &) = default;

  //! Default move constructor.
  PointGenerator2(PointGenerator2 &&) noexcept = default;

  //! Default virtual destructor.
  virtual ~PointGenerator2() = default;

  //! Default copy assignment operator.
  PointGenerator2 &operator=(const PointGenerator2 &) = default;

  //! Default move assignment operator.
  PointGenerator2 &operator=(PointGenerator2 &&) noexcept = default;

  //! Generates points to output array \p points inside given \p boundingBox
  //! with target point \p spacing.
  void generate(const BoundingBox2D &boundingBox, double spacing, Array1<Vector2D> *points) const;

  //!
  //! \brief Iterates every point within the bounding box with specified
  //! point pattern and invokes the callback function.
  //!
  //! This function iterates every point within the bounding box and invokes
  //! the callback function. The position of the point is specified by the
  //! actual implementation. The suggested spacing between the points are
  //! given by \p spacing. The input parameter of the callback function is
  //! the position of the point and the return value tells whether the
  //! iteration should stop or not.
  //!
  virtual void forEachPoint(const BoundingBox2D &boundingBox, double spacing,
                            const std::function<bool(const Vector2D &)> &callback) const = 0;
};

//! Shared pointer for the PointGenerator2 type.
using PointGenerator2Ptr = std::shared_ptr<PointGenerator2>;

} // namespace vox
} // namespace geometry

#endif // INCLUDE_JET_POINT_GENERATOR2_H_
