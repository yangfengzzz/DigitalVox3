//
//  particle_renderer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/14.
//

#ifndef particle_renderer_hpp
#define particle_renderer_hpp

#include "../renderer.h"
#include "../../../vox.geometry/particle_system_data.h"
#include "../../../vox.geometry/particle_system_solver3.h"

namespace vox {
/**
 * Particle Renderer Component.
 */
class ParticleRenderer :public Renderer {
public:
    ParticleRenderer(Entity* entity);
    
    void setParticleSystemSolver(const geometry::ParticleSystemSolver3Ptr solver);
    
    void update(float deltaTime) override;
    
private:
    geometry::ParticleSystemData3Ptr _particleSystemData;
    geometry::ParticleSystemSolver3Ptr _particleSolver;
};

}
#endif /* particle_renderer_hpp */
