// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#include "particle_emitter_set2.h"
#include "../common.h"
#include <utility>
#include <vector>

using namespace vox;
using namespace geometry;

ParticleEmitterSet2::ParticleEmitterSet2(std::vector<ParticleEmitter2Ptr> emitters) : _emitters(std::move(emitters)) {}

void ParticleEmitterSet2::addEmitter(const ParticleEmitter2Ptr &emitter) { _emitters.push_back(emitter); }

void ParticleEmitterSet2::onSetTarget(const ParticleSystemData2Ptr &particles) {
  for (auto &emitter : _emitters) {
    emitter->setTarget(particles);
  }
}

void ParticleEmitterSet2::onUpdate(double currentTimeInSeconds, double timeIntervalInSeconds) {
  if (!isEnabled()) {
    return;
  }

  for (auto &emitter : _emitters) {
    emitter->update(currentTimeInSeconds, timeIntervalInSeconds);
  }
}

ParticleEmitterSet2::Builder ParticleEmitterSet2::builder() { return Builder(); }

ParticleEmitterSet2::Builder &
ParticleEmitterSet2::Builder::withEmitters(const std::vector<ParticleEmitter2Ptr> &emitters) {
  _emitters = emitters;
  return *this;
}

ParticleEmitterSet2 ParticleEmitterSet2::Builder::build() const { return ParticleEmitterSet2(_emitters); }

ParticleEmitterSet2Ptr ParticleEmitterSet2::Builder::makeShared() const {
  return std::shared_ptr<ParticleEmitterSet2>(new ParticleEmitterSet2(_emitters),
                                              [](ParticleEmitterSet2 *obj) { delete obj; });
}
