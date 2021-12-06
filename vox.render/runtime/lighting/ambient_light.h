//
//  ambient_light.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef ambient_light_hpp
#define ambient_light_hpp

#include "../vox_type.h"
#include "../shader/shader_property.h"
#include "maths/spherical_harmonics3.h"
#include <Metal/Metal.h>
#include "../shaderlib/shader_common.h"

namespace vox {
/**
 * Diffuse mode.
 */
struct DiffuseMode {
    enum Enum {
        /** Solid color mode. */
        SolidColor,
        
        /**
         * SH mode
         * @remarks
         * Use SH3 to represent irradiance environment maps efficiently, allowing for interactive rendering of diffuse objects under distant illumination.
         */
        SphericalHarmonics
    };
};

/**
 * Ambient light.
 */
class AmbientLight {
public:
    AmbientLight(Scene* value);
    
    /**
     * Whether to decode from specularTexture with RGBM format.
     */
    bool specularTextureDecodeRGBM();

    void setSpecularTextureDecodeRGBM(bool value);
    
    /**
     * Diffuse mode of ambient light.
     */
    DiffuseMode::Enum diffuseMode();

    void setDiffuseMode(DiffuseMode::Enum value);
    
    /**
     * Diffuse reflection solid color.
     * @remarks Effective when diffuse reflection mode is `DiffuseMode.SolidColor`.
     */
    math::Color diffuseSolidColor();

    void setDiffuseSolidColor(const math::Color& value);
    
    /**
     * Diffuse reflection spherical harmonics 3.
     * @remarks Effective when diffuse reflection mode is `DiffuseMode.SphericalHarmonics`.
     */
    const math::SphericalHarmonics3& diffuseSphericalHarmonics();

    void setDiffuseSphericalHarmonics(const math::SphericalHarmonics3& value);
    
    /**
     * Diffuse reflection intensity.
     */
    float diffuseIntensity();

    void setDiffuseIntensity(float value);
    
    /**
     * Specular reflection texture.
     * @remarks This texture must be baked from @oasis-engine/baker
     */
    id<MTLTexture> specularTexture();

    void setSpecularTexture(id<MTLTexture> value);
    
    /**
     * Specular reflection intensity.
     */
    float specularIntensity();

    void setSpecularIntensity(float value);
    
private:    
    std::array<float, 27> _preComputeSH(const math::SphericalHarmonics3& sh);
    
    static ShaderProperty _envMapProperty;
    static ShaderProperty _diffuseSHProperty;
    static ShaderProperty _specularTextureProperty;
    
    Scene* _scene;
    bool _specularTextureDecodeRGBM = false;
    DiffuseMode::Enum _diffuseMode = DiffuseMode::Enum::SolidColor;
    math::SphericalHarmonics3 _diffuseSphericalHarmonics;
    std::array<float, 27> _shArray;
    id<MTLTexture> _specularReflection;
    EnvMapLight _envMapLight;
};

}
#endif /* ambient_light_hpp */
