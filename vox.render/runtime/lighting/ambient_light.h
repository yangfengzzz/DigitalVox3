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
        
        /** Texture mode. */
        Texture,
        
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
     * Diffuse reflection texture.
     * @remarks This texture must be baked from MetalLoader::createIrradianceTexture
     */
    id<MTLTexture> diffuseTexture();

    void setDiffuseTexture(id<MTLTexture> value);
    
    /**
     * Diffuse reflection intensity.
     */
    float diffuseIntensity();

    void setDiffuseIntensity(float value);
    
public:
    /**
     * Whether to decode from specularTexture with RGBM format.
     */
    bool specularTextureDecodeRGBM();

    void setSpecularTextureDecodeRGBM(bool value);
    
    /**
     * Specular reflection texture.
     * @remarks This texture must be baked from MetalLoader::createSpecularTexture
     */
    id<MTLTexture> specularTexture();

    void setSpecularTexture(id<MTLTexture> value);
    
    /**
     * Specular reflection intensity.
     */
    float specularIntensity();

    void setSpecularIntensity(float value);
    
public:
    /**
     * brdf loopup texture.
     * @remarks This texture must be baked from MetalLoader::createBRDFLookupTable
     */
    id<MTLTexture> brdfTexture();

    void setBRDFTexture(id<MTLTexture> value);
    
private:    
    std::array<float, 27> _preComputeSH(const math::SphericalHarmonics3& sh);
    
    static ShaderProperty _envMapProperty;
    static ShaderProperty _diffuseSHProperty;
    static ShaderProperty _diffuseTextureProperty;
    static ShaderProperty _specularTextureProperty;
    static ShaderProperty _brdfTextureProperty;
    
    Scene* _scene;
    EnvMapLight _envMapLight;

    DiffuseMode::Enum _diffuseMode = DiffuseMode::Enum::SolidColor;
    math::SphericalHarmonics3 _diffuseSphericalHarmonics;
    std::array<float, 27> _shArray;
    id<MTLTexture> _diffuseTexture = nullptr;

    bool _specularTextureDecodeRGBM = false;
    id<MTLTexture> _specularReflection = nullptr;
    
    id<MTLTexture> _brdfLutTexture = nullptr;
};

}
#endif /* ambient_light_hpp */
