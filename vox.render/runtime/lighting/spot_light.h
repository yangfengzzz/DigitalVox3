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
    
private:
    friend class LightManager;
    
    void _appendData(size_t lightIndex) override;
    
    static void _updateShaderData(ShaderData& shaderData);
    
    static ShaderProperty _colorProperty;
    static ShaderProperty _positionProperty;
    static ShaderProperty _directionProperty;
    static ShaderProperty _distanceProperty;
    static ShaderProperty _angleCosProperty;
    static ShaderProperty _penumbraCosProperty;
    
    static std::array<math::Color, Light::_maxLight> _combinedColor;
    static std::array<math::Float3, Light::_maxLight> _combinedPosition;
    static std::array<math::Float3, Light::_maxLight> _combinedDirection;
    static std::array<float, Light::_maxLight> _combinedDistance;
    static std::array<float, Light::_maxLight> _combinedAngleCos;
    static std::array<float, Light::_maxLight> _combinedPenumbraCos;
};

}
#endif /* spot_light_hpp */
