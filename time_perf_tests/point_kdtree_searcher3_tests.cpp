// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "../vox.geometry/array.h"
#include "../vox.geometry/point_searchers/point_kdtree_searcher.h"

#include <benchmark/benchmark.h>

#include <random>

using vox::geometry::Array1;
using vox::geometry::Vector3D;

class PointKdTreeSearcher3 : public ::benchmark::Fixture {
protected:
  std::mt19937 rng{0};
  std::uniform_real_distribution<> dist{0.0, 1.0};
  Array1<Vector3D> points;

  void SetUp(const ::benchmark::State &state) override {
    int64_t N = state.range(0);

    points.clear();
    for (int64_t i = 0; i < N; ++i) {
      points.append(makeVec());
    }
  }

  Vector3D makeVec() { return Vector3D(dist(rng), dist(rng), dist(rng)); }
};

BENCHMARK_DEFINE_F(PointKdTreeSearcher3, Build)(benchmark::State &state) {
  while (state.KeepRunning()) {
    vox::geometry::PointKdTreeSearcher3 tree;
    tree.build(points);
  }
}

BENCHMARK_REGISTER_F(PointKdTreeSearcher3, Build)->Arg(1 << 5)->Arg(1 << 10)->Arg(1 << 20);

BENCHMARK_DEFINE_F(PointKdTreeSearcher3, ForEachNearbyPoints)
(benchmark::State &state) {
  vox::geometry::PointKdTreeSearcher3 tree;
  tree.build(points);

  size_t cnt = 0;
  while (state.KeepRunning()) {
    tree.forEachNearbyPoint(makeVec(), 1.0 / 64.0, [&](size_t, const Vector3D &) { ++cnt; });
  }
}

BENCHMARK_REGISTER_F(PointKdTreeSearcher3, ForEachNearbyPoints)->Arg(1 << 5)->Arg(1 << 10)->Arg(1 << 20);
