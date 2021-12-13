// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "../vox.geometry/iteration_utils.h"
#include "../vox.geometry/matrix.h"

#include <benchmark/benchmark.h>

#include <random>

using vox::VectorND;

class MatrixMxN : public ::benchmark::Fixture {
protected:
  vox::MatrixMxND mat;
  VectorND x;
  VectorND y;

  void SetUp(const ::benchmark::State &state) override {
    std::mt19937 rng{0};
    std::uniform_real_distribution<> d(0.0, 1.0);

    const auto n = static_cast<size_t>(state.range(0));

    mat.resize(n, n);
    x.resize(n);
    y.resize(n);
    vox::forEachIndex(vox::Vector2UZ{}, vox::Vector2UZ{mat.cols(), mat.rows()},
                      [&](size_t j, size_t i) { mat(i, j) = d(rng); });
    vox::forEachIndex(x.rows(), [&](size_t i) {
      x[i] = d(rng);
      y[i] = d(rng);
    });
  }
};

BENCHMARK_DEFINE_F(MatrixMxN, Mvm)(benchmark::State &state) {
  while (state.KeepRunning()) {
    y = mat * x;
  }
}

BENCHMARK_REGISTER_F(MatrixMxN, Mvm)->Arg(1 << 8)->Arg(1 << 10)->Arg(1 << 12);
