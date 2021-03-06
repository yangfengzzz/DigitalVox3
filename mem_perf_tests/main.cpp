// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include <fstream>
#include <gtest/gtest.h>
#include "../vox.geometry/logging.h"

using namespace vox;
using namespace geometry;

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);

  std::ofstream logFile("mem_perf_tests.log");
  if (logFile) {
    Logging::setAllStream(&logFile);
  }

  int ret = RUN_ALL_TESTS();

  return ret;
}
