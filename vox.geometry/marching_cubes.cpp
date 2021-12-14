// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.
//
// Marching Cubes Example Program
// by Cory Bloyd (corysama@yahoo.com)
//
// A simple, portable and complete implementation of the Marching Cubes
// and Marching Tetrahedrons algorithms in a single source file.
// There are many ways that this code could be made faster, but the
// intent is for the code to be easy to understand.
//
// For a description of the algorithm go to
// http://astronomy.swin.edu.au/pbourke/modelling/polygonise/
//
// This code is public domain.
//

#include "common.h"
#include "marching_cubes_table.h"
#include "marching_squares_table.h"

#include "bounding_box.h"
#include "level_set_utils.h"
#include "marching_cubes.h"

#include <array>
#include <unordered_map>

namespace vox {
namespace geometry {
using MarchingCubeVertexHashKey = size_t;
using MarchingCubeVertexID = size_t;
using MarchingCubeVertexMap = std::unordered_map<MarchingCubeVertexHashKey, MarchingCubeVertexID>;

inline bool QueryVertexID(const MarchingCubeVertexMap &vertexMap, MarchingCubeVertexHashKey vKey,
                          MarchingCubeVertexID *vID) {
  const auto vIter = vertexMap.find(vKey);
  if (vIter != vertexMap.end()) {
    *vID = vIter->second;
    return true;
  }

  return false;
}

inline Vector3D Grad(const ConstArrayView3<double> &grid, ssize_t i, ssize_t j, ssize_t k,
                     const Vector3D &invGridSize) {
  Vector3D ret;
  ssize_t ip = i + 1;
  ssize_t im = i - 1;
  ssize_t jp = j + 1;
  ssize_t jm = j - 1;
  ssize_t kp = k + 1;
  ssize_t km = k - 1;
  const Vector3UZ &dim = grid.size();
  const auto dimX = static_cast<ssize_t>(dim.x);
  const auto dimY = static_cast<ssize_t>(dim.y);
  const auto dimZ = static_cast<ssize_t>(dim.z);

  if (i > dimX - 2) {
    ip = i;
  } else if (i == 0) {
    im = 0;
  }
  if (j > dimY - 2) {
    jp = j;
  } else if (j == 0) {
    jm = 0;
  }
  if (k > dimZ - 2) {
    kp = k;
  } else if (k == 0) {
    km = 0;
  }

  ret.x = 0.5 * invGridSize.x * (grid(ip, j, k) - grid(im, j, k));
  ret.y = 0.5 * invGridSize.y * (grid(i, jp, k) - grid(i, jm, k));
  ret.z = 0.5 * invGridSize.z * (grid(i, j, kp) - grid(i, j, km));

  return ret;
}

inline Vector3D SafeNormalize(const Vector3D &n) {
  if (n.lengthSquared() > 0.0) {
    return n.normalized();
  }

  return n;
}

// To compute unique edge ID, map vertices+edges into
// doubled virtual vertex indices.
//
// v  edge   v
// |----*----|    -->    |-----|-----|
// i        i+1         2i   2i+1  2i+2
//
inline size_t globalEdgeID(size_t i, size_t j, size_t k, const Vector3UZ &dim, size_t localEdgeID) {
  // See edgeConnection in marching_cubes_table.h for the edge ordering.
  static const int edgeOffset3D[12][3] = {{1, 0, 0}, {2, 0, 1}, {1, 0, 2}, {0, 0, 1}, {1, 2, 0}, {2, 2, 1},
                                          {1, 2, 2}, {0, 2, 1}, {0, 1, 0}, {2, 1, 0}, {2, 1, 2}, {0, 1, 2}};

  return ((2 * k + edgeOffset3D[localEdgeID][2]) * 2 * dim.y + (2 * j + edgeOffset3D[localEdgeID][1])) * 2 * dim.x +
         (2 * i + edgeOffset3D[localEdgeID][0]);
}

// To compute unique edge ID, map vertices+edges into
// doubled virtual vertex indices.
//
// v  edge   v
// |----*----|    -->    |-----|-----|
// i        i+1         2i   2i+1  2i+2
//
inline size_t globalVertexID(size_t i, size_t j, size_t k, const Vector3UZ &dim, size_t localVertexID) {
  // See edgeConnection in marching_cubes_table.h for the edge ordering.
  static const int vertexOffset3D[8][3] = {{0, 0, 0}, {2, 0, 0}, {2, 0, 2}, {0, 0, 2},
                                           {0, 2, 0}, {2, 2, 0}, {2, 2, 2}, {0, 2, 2}};

  return ((2 * k + vertexOffset3D[localVertexID][2]) * 2 * dim.y + (2 * j + vertexOffset3D[localVertexID][1])) * 2 *
             dim.x +
         (2 * i + vertexOffset3D[localVertexID][0]);
}

static void SingleSquare(const std::array<double, 4> &data, const std::array<size_t, 8> &vertAndEdgeIds,
                         const Vector3D &normal, const std::array<Vector3D, 4> &corners,
                         MarchingCubeVertexMap *vertexMap, TriangleMesh3 *mesh, double isoValue) {
  int idxFlags = 0;
  int idxVertexOfTheEdge[2];

  double alpha;
  Vector3D e[4];

  // Which vertices are inside? If i-th vertex is inside,
  // mark '1' at i-th bit. of 'idxFlags'.
  for (size_t iterVertex = 0; iterVertex < 4; ++iterVertex) {
    if (data[iterVertex] <= isoValue) {
      idxFlags |= 1 << iterVertex;
    }
  }

  // If the rect is entirely outside of the surface,
  // there is no job to be done in this marching-cube cell.
  if (idxFlags == 0) {
    return;
  }

  // If there are vertices which is inside the surface...
  // Which edges intersect the surface?
  // If i-th edge intersects the surface, mark '1' at i-th bit of
  // 'idxEdgeFlags'
  const int idxEdgeFlags = squareEdgeFlags[idxFlags];

  // Find the point of intersection of the surface with each edge
  for (size_t iterEdge = 0; iterEdge < 4; ++iterEdge) {
    // If there is an intersection on this edge
    if (idxEdgeFlags & (1 << iterEdge)) {
      idxVertexOfTheEdge[0] = edgeConnection2D[iterEdge][0];
      idxVertexOfTheEdge[1] = edgeConnection2D[iterEdge][1];

      // Find the phi = 0 position by iteration
      Vector3D pos0 = corners[idxVertexOfTheEdge[0]];
      Vector3D pos1 = corners[idxVertexOfTheEdge[1]];

      const double phi0 = data[idxVertexOfTheEdge[0]] - isoValue;
      const double phi1 = data[idxVertexOfTheEdge[1]] - isoValue;

      // I think it needs perturbation a little bit.
      if (std::fabs(phi0) + std::fabs(phi1) > 1e-12) {
        alpha = std::fabs(phi0) / (std::fabs(phi0) + std::fabs(phi1));
      } else {
        alpha = 0.5;
      }

      alpha = std::clamp(alpha, 0.000001, 0.999999);

      const Vector3D pos = ((1.0 - alpha) * pos0 + alpha * pos1);

      // What is the position of this vertex of the edge?
      e[iterEdge] = pos;
    }
  }

  // Make triangular patches.
  for (size_t iterTri = 0; iterTri < 4; ++iterTri) {
    // If there isn't any triangle to be built, escape this loop.
    if (triangleConnectionTable2D[idxFlags][3 * iterTri] < 0) {
      break;
    }

    Vector3UZ face;

    for (int j = 0; j < 3; ++j) {
      const int idxVertex = triangleConnectionTable2D[idxFlags][3 * iterTri + j];

      MarchingCubeVertexHashKey vKey = vertAndEdgeIds[idxVertex];
      MarchingCubeVertexID vID;

      if (QueryVertexID(*vertexMap, vKey, &vID)) {
        face[j] = vID;
      } else {
        // if vertex does not exist...
        face[j] = mesh->numberOfPoints();
        mesh->addNormal(normal);

        if (idxVertex < 4) {
          mesh->addPoint(corners[idxVertex]);
        } else {
          mesh->addPoint(e[idxVertex - 4]);
        }

        // empty texture coordinate...
        mesh->addUv(Vector2D{});
        vertexMap->insert(std::make_pair(vKey, face[j]));
      }
    }

    mesh->addPointTriangle(face);
    mesh->addNormalTriangle(face);
    mesh->addUvTriangle(face);
  }
}

static void SingleCube(const std::array<double, 8> &data, const std::array<size_t, 12> &edgeIDs,
                       const std::array<Vector3D, 8> &normals, const BoundingBox3D &bound,
                       MarchingCubeVertexMap *vertexMap, TriangleMesh3 *mesh, double isoValue) {
  int idxFlagSize = 0;
  int idxVertexOfTheEdge[2];

  Vector3D e[12], n[12];

  // Which vertices are inside? If i-th vertex is inside, mark '1' at i-th
  // bit. of 'idxFlagSize'.
  for (int iterVertex = 0; iterVertex < 8; ++iterVertex) {
    if (data[iterVertex] <= isoValue) {
      idxFlagSize |= 1 << iterVertex;
    }
  }

  // If the cube is entirely inside or outside of the surface, there is no job
  // to be done in t1his marching-cube cell.
  if (idxFlagSize == 0 || idxFlagSize == 255) {
    return;
  }

  // If there are vertices which is inside the surface...
  // Which edges intersect the surface? If i-th edge intersects the surface,
  // mark '1' at i-th bit of 'itrEdgeFlags'
  const int idxEdgeFlags = cubeEdgeFlags[idxFlagSize];

  // Find the point of intersection of the surface with each edge
  for (int iterEdge = 0; iterEdge < 12; ++iterEdge) {
    // If there is an intersection on this edge
    if (idxEdgeFlags & (1 << iterEdge)) {
      idxVertexOfTheEdge[0] = edgeConnection[iterEdge][0];
      idxVertexOfTheEdge[1] = edgeConnection[iterEdge][1];

      // cube vertex ordering to x-major ordering
      static int indexMap[8] = {0, 1, 5, 4, 2, 3, 7, 6};

      // Find the phi = 0 position
      Vector3D pos0 = bound.corner(indexMap[idxVertexOfTheEdge[0]]);
      Vector3D pos1 = bound.corner(indexMap[idxVertexOfTheEdge[1]]);

      Vector3D normal0 = normals[idxVertexOfTheEdge[0]];
      Vector3D normal1 = normals[idxVertexOfTheEdge[1]];

      const double phi0 = data[idxVertexOfTheEdge[0]] - isoValue;
      const double phi1 = data[idxVertexOfTheEdge[1]] - isoValue;

      double alpha = distanceToZeroLevelSet(phi0, phi1);

      alpha = std::clamp(alpha, 0.000001, 0.999999);

      const Vector3D pos = (1.0 - alpha) * pos0 + alpha * pos1;
      const Vector3D normal = (1.0 - alpha) * normal0 + alpha * normal1;

      e[iterEdge] = pos;
      n[iterEdge] = normal;
    }
  }

  // Make triangles
  for (int iterTri = 0; iterTri < 5; ++iterTri) {
    // If there isn't any triangle to be made, escape this loop.
    if (triangleConnectionTable3D[idxFlagSize][3 * iterTri] < 0) {
      break;
    }

    Vector3UZ face;

    for (int j = 0; j < 3; ++j) {
      int k = 3 * iterTri + j;
      MarchingCubeVertexHashKey vKey = edgeIDs[triangleConnectionTable3D[idxFlagSize][k]];
      MarchingCubeVertexID vID;

      if (QueryVertexID(*vertexMap, vKey, &vID)) {
        face[j] = vID;
      } else {
        // If vertex does not exist from the map
        face[j] = mesh->numberOfPoints();
        mesh->addNormal(SafeNormalize(n[triangleConnectionTable3D[idxFlagSize][k]]));
        mesh->addPoint(e[triangleConnectionTable3D[idxFlagSize][k]]);
        mesh->addUv(Vector2D{});
        vertexMap->insert(std::make_pair(vKey, face[j]));
      }
    }

    mesh->addPointTriangle(face);
    mesh->addNormalTriangle(face);
    mesh->addUvTriangle(face);
  }
}

void marchingCubes(const ConstArrayView3<double> &grid, const Vector3D &gridSize, const Vector3D &origin,
                   TriangleMesh3 *mesh, double isoValue, int bndClose, int bndConnectivity) {
  MarchingCubeVertexMap vertexMap;

  const Vector3UZ &dim = grid.size();
  const Vector3D invGridSize = 1.0 / gridSize;

  auto pos = [origin, gridSize](ssize_t i, ssize_t j, ssize_t k) -> Vector3D {
    return origin +
           elemMul(gridSize, Vector3D{{static_cast<double>(i), static_cast<double>(j), static_cast<double>(k)}});
  };

  const auto dimX = static_cast<ssize_t>(dim.x);
  const auto dimY = static_cast<ssize_t>(dim.y);
  const auto dimZ = static_cast<ssize_t>(dim.z);

  for (ssize_t k = 0; k < dimZ - 1; ++k) {
    for (ssize_t j = 0; j < dimY - 1; ++j) {
      for (ssize_t i = 0; i < dimX - 1; ++i) {
        std::array<double, 8> data{};
        std::array<size_t, 12> edgeIDs{};
        std::array<Vector3D, 8> normals;
        BoundingBox3D bound;

        data[0] = grid(i, j, k);
        data[1] = grid(i + 1, j, k);
        data[4] = grid(i, j + 1, k);
        data[5] = grid(i + 1, j + 1, k);
        data[3] = grid(i, j, k + 1);
        data[2] = grid(i + 1, j, k + 1);
        data[7] = grid(i, j + 1, k + 1);
        data[6] = grid(i + 1, j + 1, k + 1);

        normals[0] = Grad(grid, i, j, k, invGridSize);
        normals[1] = Grad(grid, i + 1, j, k, invGridSize);
        normals[4] = Grad(grid, i, j + 1, k, invGridSize);
        normals[5] = Grad(grid, i + 1, j + 1, k, invGridSize);
        normals[3] = Grad(grid, i, j, k + 1, invGridSize);
        normals[2] = Grad(grid, i + 1, j, k + 1, invGridSize);
        normals[7] = Grad(grid, i, j + 1, k + 1, invGridSize);
        normals[6] = Grad(grid, i + 1, j + 1, k + 1, invGridSize);

        for (int e = 0; e < 12; ++e) {
          edgeIDs[e] = globalEdgeID(i, j, k, dim, e);
        }

        bound.lowerCorner = pos(i, j, k);
        bound.upperCorner = pos(i + 1, j + 1, k + 1);

        SingleCube(data, edgeIDs, normals, bound, &vertexMap, mesh, isoValue);
      }
    }
  }

  // Construct boundaries parallel to x-y plane
  if (bndClose & (kDirectionBack | kDirectionFront)) {
    MarchingCubeVertexMap vertexMapBack;
    MarchingCubeVertexMap vertexMapFront;

    for (ssize_t j = 0; j < dimY - 1; ++j) {
      for (ssize_t i = 0; i < dimX - 1; ++i) {
        ssize_t k = 0;

        std::array<double, 4> data{};
        std::array<size_t, 8> vertexAndEdgeIDs{};
        std::array<Vector3D, 4> corners;
        Vector3D normal;

        data[0] = grid(i + 1, j, k);
        data[1] = grid(i, j, k);
        data[2] = grid(i, j + 1, k);
        data[3] = grid(i + 1, j + 1, k);

        if (bndClose & kDirectionBack) {
          normal = Vector3D{0, 0, -1};

          vertexAndEdgeIDs[0] = globalVertexID(i, j, k, dim, 1);
          vertexAndEdgeIDs[1] = globalVertexID(i, j, k, dim, 0);
          vertexAndEdgeIDs[2] = globalVertexID(i, j, k, dim, 4);
          vertexAndEdgeIDs[3] = globalVertexID(i, j, k, dim, 5);
          vertexAndEdgeIDs[4] = globalEdgeID(i, j, k, dim, 0);
          vertexAndEdgeIDs[5] = globalEdgeID(i, j, k, dim, 8);
          vertexAndEdgeIDs[6] = globalEdgeID(i, j, k, dim, 4);
          vertexAndEdgeIDs[7] = globalEdgeID(i, j, k, dim, 9);

          corners[0] = pos(i + 1, j, k);
          corners[1] = pos(i, j, k);
          corners[2] = pos(i, j + 1, k);
          corners[3] = pos(i + 1, j + 1, k);

          SingleSquare(data, vertexAndEdgeIDs, normal, corners,
                       (bndConnectivity & kDirectionBack) ? &vertexMap : &vertexMapBack, mesh, isoValue);
        }

        k = dimZ - 2;
        data[0] = grid(i, j, k + 1);
        data[1] = grid(i + 1, j, k + 1);
        data[2] = grid(i + 1, j + 1, k + 1);
        data[3] = grid(i, j + 1, k + 1);

        if (bndClose & kDirectionFront) {
          normal = Vector3D{0, 0, 1};

          vertexAndEdgeIDs[0] = globalVertexID(i, j, k, dim, 3);
          vertexAndEdgeIDs[1] = globalVertexID(i, j, k, dim, 2);
          vertexAndEdgeIDs[2] = globalVertexID(i, j, k, dim, 6);
          vertexAndEdgeIDs[3] = globalVertexID(i, j, k, dim, 7);
          vertexAndEdgeIDs[4] = globalEdgeID(i, j, k, dim, 2);
          vertexAndEdgeIDs[5] = globalEdgeID(i, j, k, dim, 10);
          vertexAndEdgeIDs[6] = globalEdgeID(i, j, k, dim, 6);
          vertexAndEdgeIDs[7] = globalEdgeID(i, j, k, dim, 11);

          corners[0] = pos(i, j, k + 1);
          corners[1] = pos(i + 1, j, k + 1);
          corners[2] = pos(i + 1, j + 1, k + 1);
          corners[3] = pos(i, j + 1, k + 1);

          SingleSquare(data, vertexAndEdgeIDs, normal, corners,
                       (bndConnectivity & kDirectionFront) ? &vertexMap : &vertexMapFront, mesh, isoValue);
        }
      }
    }
  }

  // Construct boundaries parallel to y-z plane
  if (bndClose & (kDirectionLeft | kDirectionRight)) {
    MarchingCubeVertexMap vertexMapLeft;
    MarchingCubeVertexMap vertexMapRight;

    for (ssize_t k = 0; k < dimZ - 1; ++k) {
      for (ssize_t j = 0; j < dimY - 1; ++j) {
        ssize_t i = 0;

        std::array<double, 4> data{};
        std::array<size_t, 8> vertexAndEdgeIDs{};
        std::array<Vector3D, 4> corners;
        Vector3D normal;

        data[0] = grid(i, j, k);
        data[1] = grid(i, j, k + 1);
        data[2] = grid(i, j + 1, k + 1);
        data[3] = grid(i, j + 1, k);

        if (bndClose & kDirectionLeft) {
          normal = Vector3D{-1, 0, 0};

          vertexAndEdgeIDs[0] = globalVertexID(i, j, k, dim, 0);
          vertexAndEdgeIDs[1] = globalVertexID(i, j, k, dim, 3);
          vertexAndEdgeIDs[2] = globalVertexID(i, j, k, dim, 7);
          vertexAndEdgeIDs[3] = globalVertexID(i, j, k, dim, 4);
          vertexAndEdgeIDs[4] = globalEdgeID(i, j, k, dim, 3);
          vertexAndEdgeIDs[5] = globalEdgeID(i, j, k, dim, 11);
          vertexAndEdgeIDs[6] = globalEdgeID(i, j, k, dim, 7);
          vertexAndEdgeIDs[7] = globalEdgeID(i, j, k, dim, 8);

          corners[0] = pos(i, j, k);
          corners[1] = pos(i, j, k + 1);
          corners[2] = pos(i, j + 1, k + 1);
          corners[3] = pos(i, j + 1, k);

          SingleSquare(data, vertexAndEdgeIDs, normal, corners,
                       (bndConnectivity & kDirectionLeft) ? &vertexMap : &vertexMapLeft, mesh, isoValue);
        }

        i = dimX - 2;
        data[0] = grid(i + 1, j, k + 1);
        data[1] = grid(i + 1, j, k);
        data[2] = grid(i + 1, j + 1, k);
        data[3] = grid(i + 1, j + 1, k + 1);

        if (bndClose & kDirectionRight) {
          normal = Vector3D{1, 0, 0};

          vertexAndEdgeIDs[0] = globalVertexID(i, j, k, dim, 2);
          vertexAndEdgeIDs[1] = globalVertexID(i, j, k, dim, 1);
          vertexAndEdgeIDs[2] = globalVertexID(i, j, k, dim, 5);
          vertexAndEdgeIDs[3] = globalVertexID(i, j, k, dim, 6);
          vertexAndEdgeIDs[4] = globalEdgeID(i, j, k, dim, 1);
          vertexAndEdgeIDs[5] = globalEdgeID(i, j, k, dim, 9);
          vertexAndEdgeIDs[6] = globalEdgeID(i, j, k, dim, 5);
          vertexAndEdgeIDs[7] = globalEdgeID(i, j, k, dim, 10);

          corners[0] = pos(i + 1, j, k + 1);
          corners[1] = pos(i + 1, j, k);
          corners[2] = pos(i + 1, j + 1, k);
          corners[3] = pos(i + 1, j + 1, k + 1);

          SingleSquare(data, vertexAndEdgeIDs, normal, corners,
                       (bndConnectivity & kDirectionRight) ? &vertexMap : &vertexMapRight, mesh, isoValue);
        }
      }
    }
  }

  // Construct boundaries parallel to x-z plane
  if (bndClose & (kDirectionDown | kDirectionUp)) {
    MarchingCubeVertexMap vertexMapDown;
    MarchingCubeVertexMap vertexMapUp;

    for (ssize_t k = 0; k < dimZ - 1; ++k) {
      for (ssize_t i = 0; i < dimX - 1; ++i) {
        ssize_t j = 0;

        std::array<double, 4> data{};
        std::array<size_t, 8> vertexAndEdgeIDs{};
        std::array<Vector3D, 4> corners;
        Vector3D normal;

        data[0] = grid(i, j, k);
        data[1] = grid(i + 1, j, k);
        data[2] = grid(i + 1, j, k + 1);
        data[3] = grid(i, j, k + 1);

        if (bndClose & kDirectionDown) {
          normal = Vector3D{0, -1, 0};

          vertexAndEdgeIDs[0] = globalVertexID(i, j, k, dim, 0);
          vertexAndEdgeIDs[1] = globalVertexID(i, j, k, dim, 1);
          vertexAndEdgeIDs[2] = globalVertexID(i, j, k, dim, 2);
          vertexAndEdgeIDs[3] = globalVertexID(i, j, k, dim, 3);
          vertexAndEdgeIDs[4] = globalEdgeID(i, j, k, dim, 0);
          vertexAndEdgeIDs[5] = globalEdgeID(i, j, k, dim, 1);
          vertexAndEdgeIDs[6] = globalEdgeID(i, j, k, dim, 2);
          vertexAndEdgeIDs[7] = globalEdgeID(i, j, k, dim, 3);

          corners[0] = pos(i, j, k);
          corners[1] = pos(i + 1, j, k);
          corners[2] = pos(i + 1, j, k + 1);
          corners[3] = pos(i, j, k + 1);

          SingleSquare(data, vertexAndEdgeIDs, normal, corners,
                       (bndConnectivity & kDirectionDown) ? &vertexMap : &vertexMapDown, mesh, isoValue);
        }

        j = dimY - 2;
        data[0] = grid(i + 1, j + 1, k);
        data[1] = grid(i, j + 1, k);
        data[2] = grid(i, j + 1, k + 1);
        data[3] = grid(i + 1, j + 1, k + 1);

        if (bndClose & kDirectionUp) {
          normal = Vector3D{0, 1, 0};

          vertexAndEdgeIDs[0] = globalVertexID(i, j, k, dim, 5);
          vertexAndEdgeIDs[1] = globalVertexID(i, j, k, dim, 4);
          vertexAndEdgeIDs[2] = globalVertexID(i, j, k, dim, 7);
          vertexAndEdgeIDs[3] = globalVertexID(i, j, k, dim, 6);
          vertexAndEdgeIDs[4] = globalEdgeID(i, j, k, dim, 4);
          vertexAndEdgeIDs[5] = globalEdgeID(i, j, k, dim, 7);
          vertexAndEdgeIDs[6] = globalEdgeID(i, j, k, dim, 6);
          vertexAndEdgeIDs[7] = globalEdgeID(i, j, k, dim, 5);

          corners[0] = pos(i + 1, j + 1, k);
          corners[1] = pos(i, j + 1, k);
          corners[2] = pos(i, j + 1, k + 1);
          corners[3] = pos(i + 1, j + 1, k + 1);

          SingleSquare(data, vertexAndEdgeIDs, normal, corners,
                       (bndConnectivity & kDirectionUp) ? &vertexMap : &vertexMapUp, mesh, isoValue);
        }
      }
    }
  }
}

} // namespace vox
} // namespace geometry
