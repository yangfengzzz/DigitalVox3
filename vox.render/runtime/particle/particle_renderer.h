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
    
    void _render(Camera* camera) override;
    
    //!
    //! \brief      Returns the particle system data.
    //!
    //! This function returns the particle system data. The data is created when
    //! this solver is constructed and also owned by the solver.
    //!
    //! \return     The particle system data.
    //!
    geometry::ParticleSystemData3Ptr &particleSystemData();
    
private:
    MeshPtr _createMesh();
    
private:
    geometry::ParticleSystemData3Ptr _particleSystemData;
    geometry::ParticleSystemSolver3Ptr _particleSolver;
    
    size_t _numberOfVertex = 0;
    id<MTLBuffer> _vertexBuffers;
    id<MTLBuffer> _indexBuffers;
    
    size_t _stride;
    id<MTLBuffer> _renderBuffers;
    std::vector<float> _renderRelatedInfo;
};

}
#endif /* particle_renderer_hpp */
