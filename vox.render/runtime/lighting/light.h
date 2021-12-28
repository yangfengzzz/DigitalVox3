//
//  light.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef light_hpp
#define light_hpp

#include "../component.h"
#include "maths/matrix.h"
#include "../shaderlib/shader_common.h"

namespace vox {
/**
 * Light base class.
 */
class Light : public Component {
public:
    /**
     * Each type of light source is at most 10, beyond which it will not take effect.
     * */
    static constexpr uint32_t MAX_LIGHT = 10;
    
    Light(Entity *entity);
    
    /**
     * View matrix.
     */
    math::Matrix viewMatrix();
    
    /**
     * Inverse view matrix.
     */
    math::Matrix inverseViewMatrix();
    
public:
    bool enableShadow() {
        return _enableShadow;
    }
    
    void setEnableShadow(bool enabled) {
        _enableShadow = enabled;
    }
    
    virtual math::Matrix shadowProjectionMatrix() = 0;
    
private:
    bool _enableShadow = false;
};

}

#endif /* light_hpp */
