// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "common.h"

#include "grid_emitter3.h"

using namespace vox;

void GridEmitter3::update(double currentTimeInSeconds, double timeIntervalInSeconds) {
  if (_onBeginUpdateCallback) {
    _onBeginUpdateCallback(currentTimeInSeconds, timeIntervalInSeconds);
  }

  onUpdate(currentTimeInSeconds, timeIntervalInSeconds);
}

bool GridEmitter3::isEnabled() const { return _isEnabled; }

void GridEmitter3::setIsEnabled(bool enabled) { _isEnabled = enabled; }

void GridEmitter3::setOnBeginUpdateCallback(const OnBeginUpdateCallback &callback) {
  _onBeginUpdateCallback = callback;
}
