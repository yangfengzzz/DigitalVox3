//
//  spot_light.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef spot_light_hpp
#define spot_light_hpp

#include "light.h"
#include "maths/color.h"

namespace vox {
/**
 * Spot light.
 */
class SpotLight :public Light {
public:
    /** Light color. */
    math::Color color = math::Color(1, 1, 1, 1);
    /** Light intensity. */
    float intensity = 1.0;
    /** Defines a distance cutoff at which the light's intensity must be considered zero. */
    float distance = 100;
    /** Angle, in radians, from centre of spotlight where falloff begins. */
    float angle = M_PI / 6;
    /** Angle, in radians, from falloff begins to ends. */
    float penumbra = M_PI / 12;
    
    SpotLight(Entity* entity);
    
public:
    math::Matrix shadowProjectionMatrix() override;
    
    void updateShadowMatrix();
    
    ShadowData shadow;
    
private:
    friend class LightManager;

    /**
     * Mount to the current Scene.
     */
    void _onEnable() override;
    
    /**
     * Unmount from the current Scene.
     */
    void _onDisable() override;
    
    void _updateShaderData(SpotLightData& shaderData);
};

}
#endif /* spot_light_hpp */
