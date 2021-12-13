// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "common.h"

#include "timer.h"

using namespace vox;

Timer::Timer() { _startingPoint = std::chrono::high_resolution_clock::now(); }

double Timer::durationInSeconds() const {
  auto end = std::chrono::high_resolution_clock::now();
  auto count = std::chrono::duration_cast<std::chrono::duration<double>>(end - _startingPoint).count();
  return count;
}

void Timer::reset() { _startingPoint = std::chrono::high_resolution_clock::now(); }
