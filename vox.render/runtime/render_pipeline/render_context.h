//
//  render_context.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_context_hpp
#define render_context_hpp

#include "maths/matrix.h"
#include "../vox_type.h"

namespace vox {
using namespace math;

/**
 * Rendering context.
 */
class RenderContext {
public:
    Camera *camera();
    
    const Camera *camera() const;
    
    const Scene *scene() const;
    
    const Matrix viewProjectMatrix() const;
    
    void resetContext(Scene *scene, Camera *camera);
    
private:
    Camera *_camera{nullptr};
    Scene *_scene{nullptr};
    Matrix _viewProjectMatrix;
};

}

#endif /* render_context_hpp */
