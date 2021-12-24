//
//  spot_light.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef spot_light_hpp
#define spot_light_hpp

#include "light.h"
#include "../shader/shader_property.h"
#include "../shader/shader_data.h"
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
    /**
     * Mount to the current Scene.
     */
    void _onEnable() override;
    
    /**
     * Unmount from the current Scene.
     */
    void _onDisable() override;
    
private:
    friend class LightManager;
    
    void _appendData(size_t lightIndex) override;
    
    static void _updateShaderData(ShaderData& shaderData);
    
    static ShaderProperty _spotLightProperty;
    static std::array<SpotLightData, Light::MAX_LIGHT> _shaderData;
};

}
#endif /* spot_light_hpp */
