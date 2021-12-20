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
struct RenderContext {
    Camera* _camera;
    Matrix _viewProjectMatrix = Matrix();

    void _setContext(Camera* camera);
};

}

#endif /* render_context_hpp */
