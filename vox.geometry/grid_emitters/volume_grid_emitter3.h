// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_VOLUME_GRID_EMITTER3_H_
#define INCLUDE_JET_VOLUME_GRID_EMITTER3_H_

#include "grid_emitter3.h"
#include "../grids/scalar_grid.h"
#include "../grids/vector_grid.h"

namespace vox {

//!
//! \brief 3-D grid-based volumetric emitter.
//!
class VolumeGridEmitter3 final : public GridEmitter3 {
public:
  class Builder;

  //! Maps to a scalar value for given signed-dist, location, and old value.
  using ScalarMapper = std::function<double(double, const Vector3D &, double)>;

  //! Maps to a vector value for given signed-dist, location, and old value.
  using VectorMapper = std::function<Vector3D(double, const Vector3D &, const Vector3D &)>;

  //! Constructs an emitter with a source and is-one-shot flag.
  explicit VolumeGridEmitter3(ImplicitSurface3Ptr sourceRegion, bool isOneShot = true);

  //! Default copy constructor.
  VolumeGridEmitter3(const VolumeGridEmitter3 &) = default;

  //! Default move constructor.
  VolumeGridEmitter3(VolumeGridEmitter3 &&) noexcept = default;

  //! Default virtual destructor.
  ~VolumeGridEmitter3() override = default;

  //! Default copy assignment operator.
  VolumeGridEmitter3 &operator=(const VolumeGridEmitter3 &) = default;

  //! Default move assignment operator.
  VolumeGridEmitter3 &operator=(VolumeGridEmitter3 &&) noexcept = default;

  //! Adds signed-distance target to the scalar grid.
  void addSignedDistanceTarget(const ScalarGrid3Ptr &scalarGridTarget);

  //!
  //! \brief      Adds step function target to the scalar grid.
  //!
  //! \param[in]  scalarGridTarget The scalar grid target.
  //! \param[in]  minValue         The minimum value of the step function.
  //! \param[in]  maxValue         The maximum value of the step function.
  //!
  void addStepFunctionTarget(const ScalarGrid3Ptr &scalarGridTarget, double minValue, double maxValue);

  //!
  //! \brief      Adds a scalar grid target.
  //!
  //! This function adds a custom target to the emitter. The first parameter
  //! defines which grid should it write to. The second parameter,
  //! \p customMapper, defines how to map signed-distance field from the
  //! volume geometry and location of the point to the final scalar value that
  //! is going to be written to the target grid. The third parameter defines
  //! how to blend the old value from the target grid and the new value from
  //! the mapper function.
  //!
  //! \param[in]  scalarGridTarget The scalar grid target
  //! \param[in]  customMapper     The custom mapper.
  //!
  void addTarget(const ScalarGrid3Ptr &scalarGridTarget, const ScalarMapper &customMapper);

  //!
  //! \brief      Adds a vector grid target.
  //!
  //! This function adds a custom target to the emitter. The first parameter
  //! defines which grid should it write to. The second parameter,
  //! \p customMapper, defines how to map sigend-distance field from the
  //! volume geometry and location of the point to the final vector value that
  //! is going to be written to the target grid. The third parameter defines
  //! how to blend the old value from the target grid and the new value from
  //! the mapper function.
  //!
  //! \param[in]  scalarGridTarget The vector grid target
  //! \param[in]  customMapper     The custom mapper.
  //!
  void addTarget(const VectorGrid3Ptr &vectorGridTarget, const VectorMapper &customMapper);

  //! Returns implicit surface which defines the source region.
  [[nodiscard]] const ImplicitSurface3Ptr &sourceRegion() const;

  //! Returns true if this emits only once.
  [[nodiscard]] bool isOneShot() const;

  //! Returns builder fox VolumeGridEmitter3.
  static Builder builder();

private:
  using ScalarTarget = std::tuple<ScalarGrid3Ptr, ScalarMapper>;
  using VectorTarget = std::tuple<VectorGrid3Ptr, VectorMapper>;

  ImplicitSurface3Ptr _sourceRegion;
  bool _isOneShot = true;
  bool _hasEmitted = false;
  std::vector<ScalarTarget> _customScalarTargets;
  std::vector<VectorTarget> _customVectorTargets;

  void onUpdate(double currentTimeInSeconds, double timeIntervalInSeconds) override;

  void emit();
};

//! Shared pointer type for the VolumeGridEmitter3.
using VolumeGridEmitter3Ptr = std::shared_ptr<VolumeGridEmitter3>;

//!
//! \brief Front-end to create VolumeGridEmitter3 objects step by step.
//!
class VolumeGridEmitter3::Builder final {
public:
  //! Returns builder with surface defining source region.
  Builder &withSourceRegion(const Surface3Ptr &sourceRegion);

  //! Returns builder with one-shot flag.
  Builder &withIsOneShot(bool isOneShot);

  //! Builds VolumeGridEmitter3.
  [[nodiscard]] VolumeGridEmitter3 build() const;

  //! Builds shared pointer of VolumeGridEmitter3 instance.
  [[nodiscard]] VolumeGridEmitter3Ptr makeShared() const;

private:
  ImplicitSurface3Ptr _sourceRegion;
  bool _isOneShot = true;
};

} // namespace  vox

#endif // INCLUDE_JET_VOLUME_GRID_EMITTER3_H_
