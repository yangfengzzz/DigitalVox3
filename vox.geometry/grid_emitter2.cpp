// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "common.h"

#include "grid_emitter2.h"

using namespace vox;
using namespace geometry;

void GridEmitter2::update(double currentTimeInSeconds, double timeIntervalInSeconds) {
  if (_onBeginUpdateCallback) {
    _onBeginUpdateCallback(currentTimeInSeconds, timeIntervalInSeconds);
  }

  onUpdate(currentTimeInSeconds, timeIntervalInSeconds);
}

bool GridEmitter2::isEnabled() const { return _isEnabled; }

void GridEmitter2::setIsEnabled(bool enabled) { _isEnabled = enabled; }

void GridEmitter2::setOnBeginUpdateCallback(const OnBeginUpdateCallback &callback) {
  _onBeginUpdateCallback = callback;
}
