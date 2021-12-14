// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "../vox.geometry/implicit_surfaces/implicit_surface_set.h"
#include "../vox.geometry/particle_emitter/volume_particle_emitter3.h"
#include "../vox.geometry/surfaces/box.h"
#include "../vox.geometry/timer.h"

#include <benchmark/benchmark.h>

using vox::geometry::BoundingBox3D;
using vox::geometry::Box3;
using vox::geometry::ImplicitSurfaceSet3;
using vox::geometry::ParticleSystemData3;

class VolumeParticleEmitter3 : public ::benchmark::Fixture {
protected:
  vox::geometry::VolumeParticleEmitter3Ptr emitter;

  void SetUp(const ::benchmark::State &) override {
    double dx = 0.2;
    double lx = 30.0;
    double ly = 30.0;
    double lz = 30.0;
    double pd = 0.001;

    // Build emitter
    auto box1 = Box3::builder()
                    .withLowerCorner({0, 0, 0})
                    .withUpperCorner({0.5 * lx + pd, 0.75 * ly + pd, 0.75 * lz + pd})
                    .makeShared();

    auto box2 = Box3::builder()
                    .withLowerCorner({2.5 * lx - pd, 0, 0.25 * lz - pd})
                    .withUpperCorner({3.5 * lx + pd, 0.75 * ly + pd, 1.5 * lz + pd})
                    .makeShared();

    auto boxSet =
        ImplicitSurfaceSet3::builder().withExplicitSurfaces(vox::geometry::Array1<vox::geometry::Surface3Ptr>{box1, box2}).makeShared();

    emitter = vox::geometry::VolumeParticleEmitter3::builder()
                  .withSurface(boxSet)
                  .withMaxRegion(BoundingBox3D({0, 0, 0}, {lx, ly, lz}))
                  .withSpacing(0.5 * dx)
                  .withAllowOverlapping(true)
                  .makeShared();

    auto particles = std::make_shared<ParticleSystemData3>();
    emitter->setTarget(particles);
  }
};

BENCHMARK_DEFINE_F(VolumeParticleEmitter3, Update)(benchmark::State &state) {
  while (state.KeepRunning()) {
    emitter->update(0.0, 0.01);
  }
}

BENCHMARK_REGISTER_F(VolumeParticleEmitter3, Update);
