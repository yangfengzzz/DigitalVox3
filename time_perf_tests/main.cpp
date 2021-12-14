// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "../vox.geometry/logging.h"

#include <benchmark/benchmark.h>

#include <fstream>

int main(int argc, char **argv) {
  ::benchmark::Initialize(&argc, argv);

  if (::benchmark::ReportUnrecognizedArguments(argc, argv)) {
    return 1;
  }

  vox::geometry::Logging::mute();

  ::benchmark::RunSpecifiedBenchmarks();
}
