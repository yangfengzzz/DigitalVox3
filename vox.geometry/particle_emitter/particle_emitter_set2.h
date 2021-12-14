// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_PARTICLE_EMITTER_SET2_H_
#define INCLUDE_JET_PARTICLE_EMITTER_SET2_H_

#include "../particle_emitter.h"
#include <tuple>
#include <vector>

namespace vox {
namespace geometry {

//!
//! \brief 2-D particle-based emitter set.
//!
class ParticleEmitterSet2 final : public ParticleEmitter2 {
public:
  class Builder;

  //! Default constructor.
  ParticleEmitterSet2() = default;

  //! Constructs an emitter with sub-emitters.
  explicit ParticleEmitterSet2(std::vector<ParticleEmitter2Ptr> emitters);

  //! Default copy constructor.
  ParticleEmitterSet2(const ParticleEmitterSet2 &) = default;

  //! Default move constructor.
  ParticleEmitterSet2(ParticleEmitterSet2 &&) noexcept = default;

  //! Default virtual destructor.
  ~ParticleEmitterSet2() override = default;

  //! Default copy assignment operator.
  ParticleEmitterSet2 &operator=(const ParticleEmitterSet2 &) = default;

  //! Default move assignment operator.
  ParticleEmitterSet2 &operator=(ParticleEmitterSet2 &&) noexcept = default;

  //! Adds sub-emitter.
  void addEmitter(const ParticleEmitter2Ptr &emitter);

  //! Returns builder fox ParticleEmitterSet2.
  static Builder builder();

private:
  std::vector<ParticleEmitter2Ptr> _emitters;

  void onSetTarget(const ParticleSystemData2Ptr &particles) override;

  void onUpdate(double currentTimeInSeconds, double timeIntervalInSecond) override;
};

//! Shared pointer type for the ParticleEmitterSet2.
using ParticleEmitterSet2Ptr = std::shared_ptr<ParticleEmitterSet2>;

//!
//! \brief Front-end to create ParticleEmitterSet2 objects step by step.
//!
class ParticleEmitterSet2::Builder final {
public:
  //! Returns builder with list of sub-emitters.
  Builder &withEmitters(const std::vector<ParticleEmitter2Ptr> &emitters);

  //! Builds ParticleEmitterSet2.
  [[nodiscard]] ParticleEmitterSet2 build() const;

  //! Builds shared pointer of ParticleEmitterSet2 instance.
  [[nodiscard]] ParticleEmitterSet2Ptr makeShared() const;

private:
  std::vector<ParticleEmitter2Ptr> _emitters;
};

} // namespace vox
} // namespace geometry

#endif // INCLUDE_JET_PARTICLE_EMITTER_SET2_H_
