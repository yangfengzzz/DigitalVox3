// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.
//
// This code is ported from Christopher Batty's SDFGen software.
// (https://github.com/christopherbatty/SDFGen)
//
// The MIT License (MIT)
//
// Copyright (c) 2015, Christopher Batty
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "triangle_mesh_to_sdf.h"
#include "../array.h"
#include "../array_utils.h"
#include "../common.h"
#include <algorithm>
#include <vector>

using namespace vox;
using namespace geometry;

namespace vox {
namespace geometry {
void triangleMeshToSdf(const TriangleMesh3 &mesh, ScalarGrid3 *sdf) {
  const Vector3UZ size = sdf->dataSize();
  if (size.x * size.y * size.z == 0) {
    return;
  }

  const GridDataPositionFunc<3> pos = sdf->dataPosition();
  mesh.updateQueryEngine();
  sdf->parallelForEachDataPointIndex([&](size_t i, size_t j, size_t k) {
    const Vector3D p = pos(i, j, k);
    const double d = mesh.closestDistance(p);
    const double sd = mesh.isInside(p) ? -d : d;

    (*sdf)(i, j, k) = sd;
  });
}

} // namespace vox
} // namespace geometry
