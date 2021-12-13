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

#ifndef INCLUDE_JET_TRIANGLE_MESH_TO_SDF_H_
#define INCLUDE_JET_TRIANGLE_MESH_TO_SDF_H_

#include "../grids/scalar_grid.h"
#include "../surfaces/triangle_mesh3.h"

namespace vox {
//! \brief Generates signed-distance field out of given triangle mesh.
//! This function generates signed-distance field from a triangle mesh. The sign
//! is determined by TriangleMesh3::IsInside (negative means inside).
//!
//! \param[in]      mesh	The mesh.
//! \param[in,out]  sdf     The output signed-distance field.
//!
void triangleMeshToSdf(const TriangleMesh3 &mesh, ScalarGrid3 *sdf);
} // namespace  vox

#endif // INCLUDE_JET_TRIANGLE_MESH_TO_SDF_H_
