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
#include "../shadow/light_shadow.h"

namespace vox {
/**
 * Light base class.
 */
class Light :public Component {
public:
    Light(Entity* entity);
    
    /**
     * View matrix.
     */
    math::Matrix viewMatrix();
    
    /**
     * Inverse view matrix.
     */
    math::Matrix inverseViewMatrix();
    
    virtual void _appendData(size_t lightIndex) = 0;
    
public:
    bool enableShadow() {
        return _enableShadow;
    }
    
    void setEnableShadow(bool enabled) {
        _enableShadow = enabled;
    }
    
    struct ShadowData {
        /**
         * Shadow bias.
         */
        float bias = 0.005;
        /**
         * Shadow intensity, the larger the value, the clearer and darker the shadow.
         */
        float intensity = 0.2;
        /**
         * Pixel range used for shadow PCF interpolation.
         */
        float radius = 1;
        /**
         * Light view projection matrix.
         */
        math::Matrix vp;
    } shadow;
    
    void updateShadowMatrix();
    
    virtual math::Matrix shadowProjectionMatrix() = 0;
    
protected:
    /**
     * Each type of light source is at most 10, beyond which it will not take effect.
     * */
    static constexpr size_t _maxLight = 10;
    
private:
    /**
     * Mount to the current Scene.
     */
    void _onEnable() override;
    
    /**
     * Unmount from the current Scene.
     */
    void _onDisable() override;
    
private:    
    bool _enableShadow = false;
};

}

#endif /* light_hpp */
