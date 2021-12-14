// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "../vox.geometry/timer.h"
#include <algorithm>
#include <chrono>
#include <gtest/gtest.h>
#include <thread>

using namespace vox;
using namespace geometry;

TEST(Timer, Basics) {
  Timer timer, timer2;
  std::this_thread::sleep_for(std::chrono::milliseconds(10));
  EXPECT_LT(0.01, timer.durationInSeconds());

  timer.reset();
  EXPECT_LE(timer.durationInSeconds(), timer2.durationInSeconds());
}
