//
//  point_light.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef point_light_hpp
#define point_light_hpp

#include "light.h"
#include "maths/color.h"

namespace vox {
/**
 * Point light.
 */
class PointLight : public Light {
public:
    /** Light color. */
    math::Color color = math::Color(1, 1, 1, 1);
    /** Light intensity. */
    float intensity = 1.0;
    /** Defines a distance cutoff at which the light's intensity must be considered zero. */
    float distance = 100;
    
    PointLight(Entity *entity);
    
public:
    math::Matrix shadowProjectionMatrix() override;
    
    void updateShadowMatrix();
    
    CubeShadowData shadow;
    
private:
    /**
     * Mount to the current Scene.
     */
    void _onEnable() override;
    
    /**
     * Unmount from the current Scene.
     */
    void _onDisable() override;
    
    void _updateShaderData(PointLightData &shaderData);
    
private:
    friend class LightManager;
    
    const std::array<std::pair<math::Float3, math::Float3>, 6> cubeMapDirection = {
        std::make_pair(math::Float3(10, 0, 0), math::Float3(0, 1, 0)),
        std::make_pair(math::Float3(-10, 0, 0), math::Float3(0, 1, 0)),
        std::make_pair(math::Float3(0, 10, 0), math::Float3(1, 0, 0)),
        std::make_pair(math::Float3(0, -10, 0), math::Float3(1, 0, 0)),
        std::make_pair(math::Float3(0, 0, 10), math::Float3(0, 1, 0)),
        std::make_pair(math::Float3(0, 0, -10), math::Float3(0, 1, 0)),
    };
};

}

#endif /* point_light_hpp */
