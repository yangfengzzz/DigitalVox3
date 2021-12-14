// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_GRID_EMITTER2_H_
#define INCLUDE_JET_GRID_EMITTER2_H_

#include "animation.h"
#include "grids/scalar_grid.h"
#include "implicit_surface.h"

namespace vox {
namespace geometry {

//!
//! \brief Abstract base class for 2-D grid-based emitters.
//!
class GridEmitter2 {
public:
  //!
  //! \brief Callback function type for update calls.
  //!
  //! This type of callback function will take the current time and time
  //! interval in seconds.
  //!
  using OnBeginUpdateCallback = std::function<void(double, double)>;

  //! Default constructor.
  GridEmitter2() = default;

  //! Default copy constructor.
  GridEmitter2(const GridEmitter2 &) = default;

  //! Default move constructor.
  GridEmitter2(GridEmitter2 &&) noexcept = default;

  //! Default virtual destructor.
  virtual ~GridEmitter2() = default;

  //! Default copy assignment operator.
  GridEmitter2 &operator=(const GridEmitter2 &) = default;

  //! Default copy assignment operator.
  GridEmitter2 &operator=(GridEmitter2 &&) noexcept = default;

  //! Updates the emitter state from \p currentTimeInSeconds to the following
  //! time-step.
  void update(double currentTimeInSeconds, double timeIntervalInSeconds);

  //! Returns true if the emitter is enabled.
  [[nodiscard]] bool isEnabled() const;

  //! Sets true/false to enable/disable the emitter.
  void setIsEnabled(bool enabled);

  //!
  //! \brief      Sets the callback function to be called when
  //!             GridEmitter2::update function is invoked.
  //!
  //! The callback function takes current simulation time in seconds unit. Use
  //! this callback to track any motion or state changes related to this
  //! emitter.
  //!
  //! \param[in]  callback The callback function.
  //!
  void setOnBeginUpdateCallback(const OnBeginUpdateCallback &callback);

protected:
  virtual void onUpdate(double currentTimeInSeconds, double timeIntervalInSeconds) = 0;

private:
  bool _isEnabled = true;
  OnBeginUpdateCallback _onBeginUpdateCallback;
};

//! Shared pointer type for the GridEmitter2.
using GridEmitter2Ptr = std::shared_ptr<GridEmitter2>;

} // namespace vox
} // namespace geometry

#endif // INCLUDE_JET_GRID_EMITTER2_H_
