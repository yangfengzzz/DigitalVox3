// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_PARTICLE_EMITTER_SET3_H_
#define INCLUDE_JET_PARTICLE_EMITTER_SET3_H_

#include "../particle_emitter.h"
#include <tuple>
#include <vector>

namespace vox {

//!
//! \brief 3-D particle-based emitter set.
//!
class ParticleEmitterSet3 final : public ParticleEmitter3 {
public:
  class Builder;

  //! Default constructor.
  ParticleEmitterSet3() = default;

  //! Constructs an emitter with sub-emitters.
  explicit ParticleEmitterSet3(std::vector<ParticleEmitter3Ptr> emitters);

  //! Default copy constructor.
  ParticleEmitterSet3(const ParticleEmitterSet3 &) = default;

  //! Default move constructor.
  ParticleEmitterSet3(ParticleEmitterSet3 &&) noexcept = default;

  //! Default virtual destructor.
  ~ParticleEmitterSet3() override = default;

  //! Default copy assignment operator.
  ParticleEmitterSet3 &operator=(const ParticleEmitterSet3 &) = default;

  //! Default move assignment operator.
  ParticleEmitterSet3 &operator=(ParticleEmitterSet3 &&) noexcept = default;

  //! Adds sub-emitter.
  void addEmitter(const ParticleEmitter3Ptr &emitter);

  //! Returns builder fox ParticleEmitterSet3.
  static Builder builder();

private:
  std::vector<ParticleEmitter3Ptr> _emitters;

  void onSetTarget(const ParticleSystemData3Ptr &particles) override;

  void onUpdate(double currentTimeInSeconds, double timeIntervalInSecond) override;
};

//! Shared pointer type for the ParticleEmitterSet3.
using ParticleEmitterSet3Ptr = std::shared_ptr<ParticleEmitterSet3>;

//!
//! \brief Front-end to create ParticleEmitterSet3 objects step by step.
//!
class ParticleEmitterSet3::Builder final {
public:
  //! Returns builder with list of sub-emitters.
  Builder &withEmitters(const std::vector<ParticleEmitter3Ptr> &emitters);

  //! Builds ParticleEmitterSet3.
  [[nodiscard]] ParticleEmitterSet3 build() const;

  //! Builds shared pointer of ParticleEmitterSet3 instance.
  [[nodiscard]] ParticleEmitterSet3Ptr makeShared() const;

private:
  std::vector<ParticleEmitter3Ptr> _emitters;
};

} // namespace  vox

#endif // INCLUDE_JET_PARTICLE_EMITTER_SET3_H_
