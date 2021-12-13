// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_IMPLICIT_TRIANGLE_MESH3_H_
#define INCLUDE_JET_IMPLICIT_TRIANGLE_MESH3_H_

#include "../grids/vertex_centered_scalar_grid.h"
#include "../implicit_surface.h"
#include "../surfaces/triangle_mesh3.h"
#include "custom_implicit_surface.h"

namespace vox {

//!
//! \brief  TriangleMesh3 to ImplicitSurface3 converter.
//!
//! This class builds signed-distance field for given TriangleMesh3 instance so
//! that it can be used as an ImplicitSurface3 instance. The mesh is discretized
//! into a regular grid and the signed-distance is measured at each grid point.
//! Thus, there is a sampling error and its magnitude depends on the grid
//! resolution.
//!
class ImplicitTriangleMesh3 final : public ImplicitSurface3 {
public:
  class Builder;

  //! Constructs an ImplicitSurface3 with mesh and other grid parameters.
  explicit ImplicitTriangleMesh3(const TriangleMesh3Ptr &mesh, size_t resolutionX = 32, double margin = 0.2,
                                 const Transform3 &transform = Transform3(), bool isNormalFlipped = false);

  //! Default copy constructor.
  ImplicitTriangleMesh3(const ImplicitTriangleMesh3 &) = default;

  //! Default move constructor.
  ImplicitTriangleMesh3(ImplicitTriangleMesh3 &&) noexcept = default;

  //! Default virtual destructor.
  ~ImplicitTriangleMesh3() override = default;

  //! Default copy assignment operator.
  ImplicitTriangleMesh3 &operator=(const ImplicitTriangleMesh3 &) = default;

  //! Default move assignment operator.
  ImplicitTriangleMesh3 &operator=(ImplicitTriangleMesh3 &&) noexcept = default;

  //! Returns builder fox ImplicitTriangleMesh3.
  static Builder builder();

  //! Returns grid data.
  [[nodiscard]] const VertexCenteredScalarGrid3Ptr &grid() const;

private:
  TriangleMesh3Ptr _mesh;
  VertexCenteredScalarGrid3Ptr _grid;
  CustomImplicitSurface3Ptr _customImplicitSurface;

  [[nodiscard]] Vector3D closestPointLocal(const Vector3D &otherPoint) const override;

  [[nodiscard]] double closestDistanceLocal(const Vector3D &otherPoint) const override;

  [[nodiscard]] bool intersectsLocal(const Ray3D &ray) const override;

  [[nodiscard]] BoundingBox3D boundingBoxLocal() const override;

  [[nodiscard]] Vector3D closestNormalLocal(const Vector3D &otherPoint) const override;

  [[nodiscard]] double signedDistanceLocal(const Vector3D &otherPoint) const override;

  [[nodiscard]] SurfaceRayIntersection3 closestIntersectionLocal(const Ray3D &ray) const override;
};

//! Shared pointer for the ImplicitTriangleMesh3 type.
using ImplicitTriangleMesh3Ptr = std::shared_ptr<ImplicitTriangleMesh3>;

//!
//! \brief Front-end to create ImplicitTriangleMesh3 objects step by step.
//!
class ImplicitTriangleMesh3::Builder final : public SurfaceBuilderBase3<ImplicitTriangleMesh3::Builder> {
public:
  //! Returns builder with triangle mesh.
  Builder &withTriangleMesh(const TriangleMesh3Ptr &mesh);

  //! Returns builder with resolution in x axis.
  Builder &withResolutionX(size_t resolutionX);

  //! Returns builder with margin around the mesh.
  Builder &withMargin(double margin);

  //! Builds ImplicitTriangleMesh3.
  [[nodiscard]] ImplicitTriangleMesh3 build() const;

  //! Builds shared pointer of ImplicitTriangleMesh3 instance.
  [[nodiscard]] ImplicitTriangleMesh3Ptr makeShared() const;

private:
  TriangleMesh3Ptr _mesh;
  size_t _resolutionX = 32;
  double _margin = 0.2;
};

} // namespace  vox

#endif // INCLUDE_JET_IMPLICIT_TRIANGLE_MESH3_H_
