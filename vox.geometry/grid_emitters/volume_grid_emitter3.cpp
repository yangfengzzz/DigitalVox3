// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "common.h"

#include "../grids/collocated_vector_grid.h"
#include "../grids/face_centered_grid.h"
#include "../implicit_surfaces/surface_to_implicit.h"
#include "level_set_utils.h"
#include "volume_grid_emitter3.h"

#include <algorithm>
#include <utility>

using namespace vox;
using namespace geometry;

VolumeGridEmitter3::VolumeGridEmitter3(ImplicitSurface3Ptr sourceRegion, bool isOneShot)
    : _sourceRegion(std::move(sourceRegion)), _isOneShot(isOneShot) {}

void VolumeGridEmitter3::addSignedDistanceTarget(const ScalarGrid3Ptr &scalarGridTarget) {
  auto mapper = [](double sdf, const Vector3D &, double oldVal) { return std::min(oldVal, sdf); };
  addTarget(scalarGridTarget, mapper);
}

void VolumeGridEmitter3::addStepFunctionTarget(const ScalarGrid3Ptr &scalarGridTarget, double minValue,
                                               double maxValue) {
  double smoothingWidth = scalarGridTarget->gridSpacing().min();
  auto mapper = [minValue, maxValue, smoothingWidth, scalarGridTarget](double sdf, const Vector3D &, double oldVal) {
    double step = 1.0 - smearedHeavisideSdf(sdf / smoothingWidth);
    return std::max(oldVal, (maxValue - minValue) * step + minValue);
  };
  addTarget(scalarGridTarget, mapper);
}

void VolumeGridEmitter3::addTarget(const ScalarGrid3Ptr &scalarGridTarget, const ScalarMapper &customMapper) {
  _customScalarTargets.emplace_back(scalarGridTarget, customMapper);
}

void VolumeGridEmitter3::addTarget(const VectorGrid3Ptr &vectorGridTarget, const VectorMapper &customMapper) {
  _customVectorTargets.emplace_back(vectorGridTarget, customMapper);
}

const ImplicitSurface3Ptr &VolumeGridEmitter3::sourceRegion() const { return _sourceRegion; }

bool VolumeGridEmitter3::isOneShot() const { return _isOneShot; }

void VolumeGridEmitter3::onUpdate(double currentTimeInSeconds, double timeIntervalInSeconds) {
  UNUSED_VARIABLE(currentTimeInSeconds);
  UNUSED_VARIABLE(timeIntervalInSeconds);
  if (!isEnabled()) {
    return;
  }

  emit();

  if (_isOneShot) {
    setIsEnabled(false);
  }

  _hasEmitted = true;
}

void VolumeGridEmitter3::emit() {
  if (!_sourceRegion) {
    return;
  }

  _sourceRegion->updateQueryEngine();

  for (const auto &target : _customScalarTargets) {
    const auto &grid = std::get<0>(target);
    const auto &mapper = std::get<1>(target);

    auto pos = grid->dataPosition();
    grid->parallelForEachDataPointIndex([&](size_t i, size_t j, size_t k) {
      Vector3D gx = pos(i, j, k);
      double sdf = sourceRegion()->signedDistance(gx);
      (*grid)(i, j, k) = mapper(sdf, gx, (*grid)(i, j, k));
    });
  }

  for (const auto &target : _customVectorTargets) {
    const auto &grid = std::get<0>(target);
    const auto &mapper = std::get<1>(target);

    CollocatedVectorGrid3Ptr collocated = std::dynamic_pointer_cast<CollocatedVectorGrid3>(grid);
    if (collocated != nullptr) {
      auto pos = collocated->dataPosition();
      collocated->parallelForEachDataPointIndex([&](size_t i, size_t j, size_t k) {
        Vector3D gx = pos(i, j, k);
        double sdf = sourceRegion()->signedDistance(gx);
        if (isInsideSdf(sdf)) {
          (*collocated)(i, j, k) = mapper(sdf, gx, (*collocated)(i, j, k));
        }
      });
      continue;
    }

    FaceCenteredGrid3Ptr faceCentered = std::dynamic_pointer_cast<FaceCenteredGrid3>(grid);
    if (faceCentered != nullptr) {
      auto uPos = faceCentered->uPosition();
      auto vPos = faceCentered->vPosition();
      auto wPos = faceCentered->wPosition();

      faceCentered->parallelForEachUIndex([&](const Vector3UZ &idx) {
        Vector3D gx = uPos(idx);
        double sdf = sourceRegion()->signedDistance(gx);
        Vector3D oldVal = faceCentered->sample(gx);
        Vector3D newVal = mapper(sdf, gx, oldVal);
        faceCentered->u(idx) = newVal.x;
      });
      faceCentered->parallelForEachVIndex([&](const Vector3UZ &idx) {
        Vector3D gx = vPos(idx);
        double sdf = sourceRegion()->signedDistance(gx);
        Vector3D oldVal = faceCentered->sample(gx);
        Vector3D newVal = mapper(sdf, gx, oldVal);
        faceCentered->v(idx) = newVal.y;
      });
      faceCentered->parallelForEachWIndex([&](const Vector3UZ &idx) {
        Vector3D gx = wPos(idx);
        double sdf = sourceRegion()->signedDistance(gx);
        Vector3D oldVal = faceCentered->sample(gx);
        Vector3D newVal = mapper(sdf, gx, oldVal);
        faceCentered->w(idx) = newVal.z;
      });
      continue;
    }
  }
}

VolumeGridEmitter3::Builder VolumeGridEmitter3::builder() { return Builder(); }

VolumeGridEmitter3::Builder &VolumeGridEmitter3::Builder::withSourceRegion(const Surface3Ptr &sourceRegion) {
  auto implicit = std::dynamic_pointer_cast<ImplicitSurface3>(sourceRegion);
  if (implicit != nullptr) {
    _sourceRegion = implicit;
  } else {
    _sourceRegion = std::make_shared<SurfaceToImplicit3>(sourceRegion);
  }
  return *this;
}

VolumeGridEmitter3::Builder &VolumeGridEmitter3::Builder::withIsOneShot(bool isOneShot) {
  _isOneShot = isOneShot;
  return *this;
}

VolumeGridEmitter3 VolumeGridEmitter3::Builder::build() const { return VolumeGridEmitter3(_sourceRegion, _isOneShot); }

VolumeGridEmitter3Ptr VolumeGridEmitter3::Builder::makeShared() const {
  return std::shared_ptr<VolumeGridEmitter3>(new VolumeGridEmitter3(_sourceRegion, _isOneShot),
                                             [](VolumeGridEmitter3 *obj) { delete obj; });
}
