//
//  particle_renderer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/14.
//

#ifndef particle_renderer_hpp
#define particle_renderer_hpp

#include "../renderer.h"

namespace vox {
/**
 * Particle Renderer Component.
 */
class ParticleRenderer :public Renderer {
public:
    ParticleRenderer(Entity* entity);
    
private:
    
};

}
#endif /* particle_renderer_hpp */
