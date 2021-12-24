//
//  direct_light.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef direct_light_hpp
#define direct_light_hpp

#include "light.h"
#include "../shader/shader_property.h"
#include "../shader/shader_data.h"
#include "maths/color.h"

namespace vox {
/**
 * Directional light.
 */
class DirectLight :public Light {
public:
    /** Light color. */
    math::Color color = math::Color(1, 1, 1, 1);
    /** Light intensity. */
    float intensity = 1.0;
    
    DirectLight(Entity* entity);
    
public:
    math::Matrix shadowProjectionMatrix() override;
    
    math::Float3 direction();
    
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
    
    static ShaderProperty _directLightProperty;
    static std::array<DirectLightData, Light::MAX_LIGHT> _shaderData;
};

}
#endif /* direct_light_hpp */
