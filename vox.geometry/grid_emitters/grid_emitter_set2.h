// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_GRID_EMITTER_SET2_H_
#define INCLUDE_JET_GRID_EMITTER_SET2_H_

#include "grid_emitter2.h"
#include <tuple>
#include <vector>

namespace vox {
namespace geometry {

//!
//! \brief 2-D grid-based emitter set.
//!
class GridEmitterSet2 final : public GridEmitter2 {
public:
  class Builder;

  //! Default constructor.
  GridEmitterSet2() = default;

  //! Constructs an emitter with sub-emitters.
  explicit GridEmitterSet2(const std::vector<GridEmitter2Ptr> &emitters);

  //! Default copy constructor.
  GridEmitterSet2(const GridEmitterSet2 &) = default;

  //! Default move constructor.
  GridEmitterSet2(GridEmitterSet2 &&) noexcept = default;

  //! Default virtual destructor.
  ~GridEmitterSet2() override = default;

  //! Default copy assignment operator.
  GridEmitterSet2 &operator=(const GridEmitterSet2 &) = default;

  //! Default move assignment operator.
  GridEmitterSet2 &operator=(GridEmitterSet2 &&) noexcept = default;

  //! Adds sub-emitter.
  void addEmitter(const GridEmitter2Ptr &emitter);

  //! Returns builder fox GridEmitterSet2.
  static Builder builder();

private:
  std::vector<GridEmitter2Ptr> _emitters;

  void onUpdate(double currentTimeInSeconds, double timeIntervalInSeconds) override;
};

//! Shared pointer type for the GridEmitterSet2.
using GridEmitterSet2Ptr = std::shared_ptr<GridEmitterSet2>;

//!
//! \brief Front-end to create GridEmitterSet2 objects step by step.
//!
class GridEmitterSet2::Builder final {
public:
  //! Returns builder with list of sub-emitters.
  Builder &withEmitters(const std::vector<GridEmitter2Ptr> &emitters);

  //! Builds GridEmitterSet2.
  [[nodiscard]] GridEmitterSet2 build() const;

  //! Builds shared pointer of GridEmitterSet2 instance.
  [[nodiscard]] GridEmitterSet2Ptr makeShared() const;

private:
  std::vector<GridEmitter2Ptr> _emitters;
};

} // namespace vox
} // namespace geometry

#endif // INCLUDE_JET_GRID_EMITTER_SET2_H_
