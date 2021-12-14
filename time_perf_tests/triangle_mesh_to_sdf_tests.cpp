//
// Created by 杨丰 on 2021/4/26.
//

#include "benchmark/benchmark.h"

#include "../vox.geometry/grids/vertex_centered_scalar_grid.h"
#include "../vox.geometry/implicit_surfaces/triangle_mesh_to_sdf.h"

#include <fstream>
#include <random>

using vox::geometry::Vector3D;

class TriangleMeshToSDF : public ::benchmark::Fixture {
protected:
  std::mt19937 rng{0};
  std::uniform_real_distribution<> dist{0.0, 1.0};
  vox::geometry::TriangleMesh3 triMesh;
  vox::geometry::VertexCenteredScalarGrid3 grid;

  void SetUp(const ::benchmark::State &) override {
    std::ifstream file("../models/bunny.obj");

    if (file) {
      [[maybe_unused]] bool isLoaded = triMesh.readObj(&file);
      file.close();
    }

    vox::geometry::BoundingBox3D box = triMesh.boundingBox();
    const Vector3D scale{box.width(), box.height(), box.depth()};
    box.lowerCorner -= 0.2 * scale;
    box.upperCorner += 0.2 * scale;

    grid.resize({100, 100, 100}, {box.width() / 100, box.height() / 100, box.depth() / 100},
                {box.lowerCorner.x, box.lowerCorner.y, box.lowerCorner.z});
  }
};

BENCHMARK_DEFINE_F(TriangleMeshToSDF, Call)(benchmark::State &state) {
  while (state.KeepRunning()) {
    vox::geometry::triangleMeshToSdf(triMesh, &grid);
  }
}

BENCHMARK_REGISTER_F(TriangleMeshToSDF, Call)->Unit(benchmark::kMillisecond);
