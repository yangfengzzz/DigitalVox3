//
//  point_light.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef point_light_hpp
#define point_light_hpp

#include "light.h"
#include "../shader/shader_property.h"
#include "../shader/shader_data.h"
#include "maths/color.h"

namespace vox {
/**
 * Point light.
 */
class PointLight :public Light {
public:
    /** Light color. */
    math::Color color = math::Color(1, 1, 1, 1);
    /** Light intensity. */
    float intensity = 1.0;
    /** Defines a distance cutoff at which the light's intensity must be considered zero. */
    float distance = 100;
    
    PointLight(Entity* entity);
    
public:
    math::Matrix shadowProjectionMatrix() override;
    
private:
    friend class LightManager;
    
    void _appendData(size_t lightIndex) override;
    
    static void _updateShaderData(ShaderData& shaderData);
    
    static ShaderProperty _colorProperty;
    static ShaderProperty _positionProperty;
    static ShaderProperty _distanceProperty;
    
    static std::array<math::Color, Light::MAX_LIGHT> _combinedColor;
    static std::array<math::Float3, Light::MAX_LIGHT> _combinedPosition;
    static std::array<float, Light::MAX_LIGHT> _combinedDistance;
};

}

#endif /* point_light_hpp */
