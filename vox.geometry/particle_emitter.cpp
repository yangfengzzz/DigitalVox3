// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "common.h"

#include "particle_emitter.h"

namespace vox {
namespace geometry {

template <size_t N> const ParticleSystemDataPtr<N> &ParticleEmitter<N>::target() const { return _particles; }

template <size_t N> void ParticleEmitter<N>::setTarget(const ParticleSystemDataPtr<N> &particles) {
  _particles = particles;

  onSetTarget(particles);
}

template <size_t N> void ParticleEmitter<N>::update(double currentTimeInSeconds, double timeIntervalInSeconds) {
  if (_onBeginUpdateCallback) {
    _onBeginUpdateCallback(this, currentTimeInSeconds, timeIntervalInSeconds);
  }

  onUpdate(currentTimeInSeconds, timeIntervalInSeconds);
}

template <size_t N> bool ParticleEmitter<N>::isEnabled() const { return _isEnabled; }

template <size_t N> void ParticleEmitter<N>::setIsEnabled(bool enabled) { _isEnabled = enabled; }

template <size_t N> void ParticleEmitter<N>::onSetTarget(const ParticleSystemDataPtr<N> &particles) {
  UNUSED_VARIABLE(particles);
}

template <size_t N> void ParticleEmitter<N>::setOnBeginUpdateCallback(const OnBeginUpdateCallback &callback) {
  _onBeginUpdateCallback = callback;
}

template class ParticleEmitter<2>;

template class ParticleEmitter<3>;

} // namespace vox
} // namespace geometry
