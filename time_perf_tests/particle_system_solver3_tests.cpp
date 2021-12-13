// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "../vox.geometry/colliders/rigid_body_collider.h"
#include "../vox.geometry/constants.h"
#include "../vox.geometry/particle_system_solver3.h"
#include "../vox.geometry/surfaces/plane.h"

#include <benchmark/benchmark.h>

#include <random>

class ParticleSystemSolver3 : public benchmark::Fixture {
public:
  std::mt19937 rng{0};
  std::uniform_real_distribution<> dist{0.0, 1.0};
  vox::Array1<vox::Vector3D> points;
  vox::ParticleSystemSolver3 solver;
  vox::Frame frame{0, 1.0 / 300.0};

  void SetUp(benchmark::State &state) override {
    auto plane = std::make_shared<vox::Plane3>(vox::Vector3D(0, 1, 0), vox::Vector3D());
    auto collider = std::make_shared<vox::RigidBodyCollider3>(plane);

    solver.setCollider(collider);
    solver.setDragCoefficient(0.0);
    solver.setRestitutionCoefficient(1.0);

    auto numParticles = static_cast<size_t>(state.range(0));
    auto &particles = solver.particleSystemData();

    points.clear();
    for (size_t i = 0; i < numParticles; ++i) {
      points.append(makeVec());
    }
    particles->resize(0);
    particles->addParticles(points);
  }

  void SetUp(const benchmark::State &) override {}

  void TearDown(benchmark::State &) override {}

  void TearDown(const benchmark::State &) override {}

  void update() {
    solver.update(frame);
    frame.advance();
  }

  vox::Vector3D makeVec() { return vox::Vector3D(dist(rng), dist(rng), dist(rng)); }
};

BENCHMARK_DEFINE_F(ParticleSystemSolver3, Update)
(benchmark::State &state) {
  using namespace std::chrono;

  while (state.KeepRunning()) {
    auto start = high_resolution_clock::now();
    update();
    auto end = high_resolution_clock::now();

    auto elapsed_seconds = duration_cast<duration<double>>(end - start);

    state.SetIterationTime(elapsed_seconds.count());
  }
}
BENCHMARK_REGISTER_F(ParticleSystemSolver3, Update)
    ->Arg(1 << 14)
    ->Arg(1 << 18)
    ->UseManualTime()
    ->Unit(benchmark::kMicrosecond);
