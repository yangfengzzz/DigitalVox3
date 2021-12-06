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
};

}

#endif /* light_hpp */
