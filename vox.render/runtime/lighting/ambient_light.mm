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
ShaderProperty AmbientLight::_envMapProperty = Shader::createProperty("u_envMapLight", ShaderDataGroup::Enum::Scene);
ShaderProperty AmbientLight::_diffuseSHProperty = Shader::createProperty("u_env_sh", ShaderDataGroup::Enum::Scene);
ShaderProperty AmbientLight::_specularTextureProperty  = Shader::createProperty("u_env_specularTexture", ShaderDataGroup::Enum::Scene);

AmbientLight::AmbientLight(Scene* value) {
    _scene = value;
    if (!value) return;
    
    _envMapLight.diffuse = simd_make_float3(0.212, 0.227, 0.259);
    _envMapLight.diffuseIntensity = 1.0;
    _envMapLight.specularIntensity = 1.0;
    _scene->shaderData.setData(AmbientLight::_envMapProperty, _envMapLight);
}

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
    return math::Color(_envMapLight.diffuse.x, _envMapLight.diffuse.y, _envMapLight.diffuse.z);
}

void AmbientLight::setDiffuseSolidColor(const math::Color& value) {
    _envMapLight.diffuse = simd_make_float3(value.r, value.g, value.b);
}

const math::SphericalHarmonics3& AmbientLight::diffuseSphericalHarmonics() {
    return _diffuseSphericalHarmonics;
}

void AmbientLight::setDiffuseSphericalHarmonics(const math::SphericalHarmonics3& value) {
    _diffuseSphericalHarmonics = value;
    if (!_scene) return;
    
    _scene->shaderData.setData(AmbientLight::_diffuseSHProperty, _preComputeSH(value));
}

float AmbientLight::diffuseIntensity() {
    return _envMapLight.diffuseIntensity;
}

void AmbientLight::setDiffuseIntensity(float value) {
    _envMapLight.diffuseIntensity = value;
    if (!_scene) return;

    _scene->shaderData.setData(AmbientLight::_envMapProperty, _envMapLight);
}

id<MTLTexture> AmbientLight::specularTexture() {
    return _specularReflection;
}

void AmbientLight::setSpecularTexture(id<MTLTexture> value) {
    _specularReflection = value;
    if (!_scene) return;

    auto& shaderData = _scene->shaderData;

    if (value) {
      shaderData.setData(AmbientLight::_envMapProperty, _envMapLight);
      shaderData.enableMacro(HAS_SPECULAR_ENV);
    } else {
      shaderData.disableMacro(HAS_SPECULAR_ENV);
    }
}

float AmbientLight::specularIntensity() {
    return _envMapLight.specularIntensity;
}

void AmbientLight::setSpecularIntensity(float value) {
    _envMapLight.specularIntensity = value;
    if (!_scene) return;

    _scene->shaderData.setData(AmbientLight::_envMapProperty, _envMapLight);
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
