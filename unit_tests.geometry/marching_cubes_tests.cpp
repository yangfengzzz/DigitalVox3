//
// Created by 杨丰 on 2021/4/27.
//

#include "../vox.geometry/array.h"
#include "../vox.geometry/marching_cubes.h"
#include <gtest/gtest.h>
using namespace vox;
using namespace geometry;

TEST(MarchingCubes, Connectivity) {
  TriangleMesh3 triMesh;

  Array3<double> grid{2, 2, 2};
  grid(0, 0, 0) = -0.5;
  grid(0, 0, 1) = -0.5;
  grid(0, 1, 0) = 0.5;
  grid(0, 1, 1) = 0.5;
  grid(1, 0, 0) = -0.5;
  grid(1, 0, 1) = -0.5;
  grid(1, 1, 0) = 0.5;
  grid(1, 1, 1) = 0.5;

  marchingCubes(grid, Vector3D(1, 1, 1), Vector3D(), &triMesh, 0, kDirectionAll, kDirectionNone);
  EXPECT_EQ(24u, triMesh.numberOfPoints());

  triMesh.clear();
  marchingCubes(grid, Vector3D(1, 1, 1), Vector3D(), &triMesh, 0, kDirectionAll, kDirectionBack);
  EXPECT_EQ(22u, triMesh.numberOfPoints());

  triMesh.clear();
  marchingCubes(grid, Vector3D(1, 1, 1), Vector3D(), &triMesh, 0, kDirectionAll, kDirectionFront);
  EXPECT_EQ(22u, triMesh.numberOfPoints());

  triMesh.clear();
  marchingCubes(grid, Vector3D(1, 1, 1), Vector3D(), &triMesh, 0, kDirectionAll, kDirectionLeft);
  EXPECT_EQ(22u, triMesh.numberOfPoints());

  triMesh.clear();
  marchingCubes(grid, Vector3D(1, 1, 1), Vector3D(), &triMesh, 0, kDirectionAll, kDirectionRight);
  EXPECT_EQ(22u, triMesh.numberOfPoints());

  triMesh.clear();
  marchingCubes(grid, Vector3D(1, 1, 1), Vector3D(), &triMesh, 0, kDirectionAll, kDirectionDown);
  EXPECT_EQ(24u, triMesh.numberOfPoints());

  triMesh.clear();
  marchingCubes(grid, Vector3D(1, 1, 1), Vector3D(), &triMesh, 0, kDirectionAll, kDirectionUp);
  EXPECT_EQ(24u, triMesh.numberOfPoints());

  triMesh.clear();
  marchingCubes(grid, Vector3D(1, 1, 1), Vector3D(), &triMesh, 0, kDirectionAll, kDirectionAll);
  EXPECT_EQ(8u, triMesh.numberOfPoints());
}
