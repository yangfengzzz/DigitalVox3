//
//  ambient_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "ambient_light.h"
#include "../shader/shader.h"
#include "../scene.h"

namespace vox {
ShaderProperty AmbientLight::_envMapProperty = Shader::createProperty("u_envMapLight", ShaderDataGroup::Scene);
ShaderProperty AmbientLight::_diffuseSHProperty = Shader::createProperty("u_env_sh", ShaderDataGroup::Scene);
ShaderProperty AmbientLight::_specularTextureProperty  = Shader::createProperty("u_env_specularTexture", ShaderDataGroup::Scene);

bool AmbientLight::specularTextureDecodeRGBM() {
    return _specularTextureDecodeRGBM;
}

void AmbientLight::setSpecularTextureDecodeRGBM(bool value) {
    
}

DiffuseMode::Enum AmbientLight::diffuseMode() {
    return _diffuseMode;
}

void AmbientLight::setDiffuseMode(DiffuseMode::Enum value) {
    _diffuseMode = value;
    if (!_scene) return;
    
    if (value == DiffuseMode::Enum::SphericalHarmonics) {
        _scene->shaderData.enableMacro(HAS_SH);
    } else {
        _scene->shaderData.disableMacro(HAS_SH);
    }
}

math::Color AmbientLight::diffuseSolidColor() {
    return _diffuseSolidColor;
}

void AmbientLight::setDiffuseSolidColor(const math::Color& value) {
    
}

const math::SphericalHarmonics3& AmbientLight::diffuseSphericalHarmonics() {
    return _diffuseSphericalHarmonics;
}

void AmbientLight::setDiffuseSphericalHarmonics(const math::SphericalHarmonics3& value) {
    
}

float AmbientLight::diffuseIntensity() {
    return _diffuseIntensity;
}

void AmbientLight::setDiffuseIntensity(float value) {
    
}

id<MTLTexture> AmbientLight::specularTexture() {
    return _specularReflection;
}

void AmbientLight::setSpecularTexture(id<MTLTexture> value) {
    
}

float AmbientLight::specularIntensity() {
    return _specularIntensity;
}

void AmbientLight::setSpecularIntensity(float value) {
    
}

void AmbientLight::_setScene(Scene* value) {
    
}

std::array<float, 27> AmbientLight::_preComputeSH(const math::SphericalHarmonics3& sh) {
    /**
     * Basis constants
     *
     * 0: 1/2 * Math.sqrt(1 / Math.PI)
     *
     * 1: -1/2 * Math.sqrt(3 / Math.PI)
     * 2: 1/2 * Math.sqrt(3 / Math.PI)
     * 3: -1/2 * Math.sqrt(3 / Math.PI)
     *
     * 4: 1/2 * Math.sqrt(15 / Math.PI)
     * 5: -1/2 * Math.sqrt(15 / Math.PI)
     * 6: 1/4 * Math.sqrt(5 / Math.PI)
     * 7: -1/2 * Math.sqrt(15 / Math.PI)
     * 8: 1/4 * Math.sqrt(15 / Math.PI)
     */
    
    /**
     * Convolution kernel
     *
     * 0: Math.PI
     * 1: (2 * Math.PI) / 3
     * 2: Math.PI / 4
     */
    
    const auto& src = sh.coefficients();
    std::array<float, 27> out;
    // l0
    out[0] = src[0] * 0.886227; // kernel0 * basis0 = 0.886227
    out[1] = src[1] * 0.886227;
    out[2] = src[2] * 0.886227;
    
    // l1
    out[3] = src[3] * -1.023327; // kernel1 * basis1 = -1.023327;
    out[4] = src[4] * -1.023327;
    out[5] = src[5] * -1.023327;
    out[6] = src[6] * 1.023327; // kernel1 * basis2 = 1.023327
    out[7] = src[7] * 1.023327;
    out[8] = src[8] * 1.023327;
    out[9] = src[9] * -1.023327; // kernel1 * basis3 = -1.023327
    out[10] = src[10] * -1.023327;
    out[11] = src[11] * -1.023327;
    
    // l2
    out[12] = src[12] * 0.858086; // kernel2 * basis4 = 0.858086
    out[13] = src[13] * 0.858086;
    out[14] = src[14] * 0.858086;
    out[15] = src[15] * -0.858086; // kernel2 * basis5 = -0.858086
    out[16] = src[16] * -0.858086;
    out[17] = src[17] * -0.858086;
    out[18] = src[18] * 0.247708; // kernel2 * basis6 = 0.247708
    out[19] = src[19] * 0.247708;
    out[20] = src[20] * 0.247708;
    out[21] = src[21] * -0.858086; // kernel2 * basis7 = -0.858086
    out[22] = src[22] * -0.858086;
    out[23] = src[23] * -0.858086;
    out[24] = src[24] * 0.429042; // kernel2 * basis8 = 0.429042
    out[25] = src[25] * 0.429042;
    out[26] = src[26] * 0.429042;
    
    return out;
}

}
