// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_GRID_EMITTER3_H_
#define INCLUDE_JET_GRID_EMITTER3_H_

#include "animation.h"
#include "grids/scalar_grid.h"
#include "implicit_surface.h"

namespace vox {

//!
//! \brief Abstract base class for 3-D grid-based emitters.
//!
class GridEmitter3 {
public:
  //!
  //! \brief Callback function type for update calls.
  //!
  //! This type of callback function will take the current time and time
  //! interval in seconds.
  //!
  using OnBeginUpdateCallback = std::function<void(double, double)>;

  //! Default constructor.
  GridEmitter3() = default;

  //! Default copy constructor.
  GridEmitter3(const GridEmitter3 &) = default;

  //! Default move constructor.
  GridEmitter3(GridEmitter3 &&) noexcept = default;

  //! Default virtual destructor.
  virtual ~GridEmitter3() = default;

  //! Default copy assignment operator.
  GridEmitter3 &operator=(const GridEmitter3 &) = default;

  //! Default copy assignment operator.
  GridEmitter3 &operator=(GridEmitter3 &&) noexcept = default;

  //! Updates the emitter state from \p currentTimeInSeconds to the following
  //! time-step.
  void update(double currentTimeInSeconds, double timeIntervalInSeconds);

  //! Returns true if the emitter is enabled.
  [[nodiscard]] bool isEnabled() const;

  //! Sets true/false to enable/disable the emitter.
  void setIsEnabled(bool enabled);

  //!
  //! \brief      Sets the callback function to be called when
  //!             GridEmitter3::update function is invoked.
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

//! Shared pointer type for the GridEmitter3.
using GridEmitter3Ptr = std::shared_ptr<GridEmitter3>;

} // namespace  vox

#endif // INCLUDE_JET_GRID_EMITTER3_H_
