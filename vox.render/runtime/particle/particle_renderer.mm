//
//  particle_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/14.
//

#include "particle_renderer.h"

namespace vox {
ParticleRenderer::ParticleRenderer(Entity* entity):
Renderer(entity) {}

void ParticleRenderer::setParticleSystemSolver(const geometry::ParticleSystemSolver3Ptr solver) {
    _particleSolver = solver;
    solver->setParticleSystemData(_particleSystemData);
}

void ParticleRenderer::update(float deltaTime) {
    if (_particleSolver) {
        _particleSolver->advanceSingleFrame();
    }
    
    
}

}
