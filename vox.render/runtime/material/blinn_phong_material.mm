//
//  blinn_phong_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "blinn_phong_material.h"

namespace vox {
ShaderProperty BlinnPhongMaterial::_diffuseColorProp = Shader::createProperty("u_diffuseColor", ShaderDataGroup::Material);
ShaderProperty BlinnPhongMaterial::_specularColorProp = Shader::createProperty("u_specularColor", ShaderDataGroup::Material);
ShaderProperty BlinnPhongMaterial::_emissiveColorProp = Shader::createProperty("u_emissiveColor", ShaderDataGroup::Material);
ShaderProperty BlinnPhongMaterial::_tilingOffsetProp = Shader::createProperty("u_tilingOffset", ShaderDataGroup::Material);
ShaderProperty BlinnPhongMaterial::_shininessProp = Shader::createProperty("u_shininess", ShaderDataGroup::Material);
ShaderProperty BlinnPhongMaterial::_normalIntensityProp = Shader::createProperty("u_normalIntensity", ShaderDataGroup::Material);

ShaderProperty BlinnPhongMaterial::_baseTextureProp = Shader::createProperty("u_diffuseTexture", ShaderDataGroup::Material);
ShaderProperty BlinnPhongMaterial::_specularTextureProp = Shader::createProperty("u_specularTexture", ShaderDataGroup::Material);
ShaderProperty BlinnPhongMaterial::_emissiveTextureProp = Shader::createProperty("u_emissiveTexture", ShaderDataGroup::Material);
ShaderProperty BlinnPhongMaterial::_normalTextureProp = Shader::createProperty("u_normalTexture", ShaderDataGroup::Material);

math::Color BlinnPhongMaterial::baseColor() {
    return std::any_cast<math::Color>(shaderData.getData(BlinnPhongMaterial::_diffuseColorProp));
}

void BlinnPhongMaterial::setBaseColor(const math::Color &newValue) {
    shaderData.setData(BlinnPhongMaterial::_diffuseColorProp, newValue);
}

id <MTLTexture> BlinnPhongMaterial::baseTexture() {
    return std::any_cast<id <MTLTexture>>(shaderData.getData(BlinnPhongMaterial::_baseTextureProp));
}

void BlinnPhongMaterial::setBaseTexture(id <MTLTexture> newValue) {
    shaderData.setData(BlinnPhongMaterial::_baseTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_DIFFUSE_TEXTURE);
    } else {
        shaderData.disableMacro(HAS_DIFFUSE_TEXTURE);
    }
}

math::Color BlinnPhongMaterial::specularColor() {
    return std::any_cast<math::Color>(shaderData.getData(BlinnPhongMaterial::_specularColorProp));
}

void BlinnPhongMaterial::setSpecularColor(const math::Color &newValue) {
    shaderData.setData(BlinnPhongMaterial::_specularColorProp, newValue);
}

id <MTLTexture> BlinnPhongMaterial::specularTexture() {
    return std::any_cast<id <MTLTexture>>(shaderData.getData(BlinnPhongMaterial::_specularTextureProp));
}

void BlinnPhongMaterial::setSpecularTexture(id <MTLTexture> newValue) {
    shaderData.setData(BlinnPhongMaterial::_specularTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_SPECULAR_TEXTURE);
    } else {
        shaderData.disableMacro(HAS_SPECULAR_TEXTURE);
    }
}

math::Color BlinnPhongMaterial::emissiveColor() {
    return std::any_cast<math::Color>(shaderData.getData(BlinnPhongMaterial::_emissiveColorProp));
}

void BlinnPhongMaterial::setEmissiveColor(const math::Color &newValue) {
    shaderData.setData(BlinnPhongMaterial::_emissiveColorProp, newValue);
}

id <MTLTexture> BlinnPhongMaterial::emissiveTexture() {
    return std::any_cast<id <MTLTexture>>(shaderData.getData(BlinnPhongMaterial::_emissiveTextureProp));
}

void BlinnPhongMaterial::BlinnPhongMaterial::setEmissiveTexture(id <MTLTexture> newValue) {
    shaderData.setData(BlinnPhongMaterial::_emissiveTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_EMISSIVE_TEXTURE);
    } else {
        shaderData.disableMacro(HAS_EMISSIVE_TEXTURE);
    }
}

id <MTLTexture> BlinnPhongMaterial::normalTexture() {
    return std::any_cast<id <MTLTexture>>(shaderData.getData(BlinnPhongMaterial::_normalTextureProp));
}

void BlinnPhongMaterial::setNormalTexture(id <MTLTexture> newValue) {
    shaderData.setData(BlinnPhongMaterial::_normalTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_NORMAL_TEXTURE);
    } else {
        shaderData.disableMacro(HAS_NORMAL_TEXTURE);
    }
}

float BlinnPhongMaterial::normalIntensity() {
    return std::any_cast<float>(shaderData.getData(BlinnPhongMaterial::_normalIntensityProp));
}

void BlinnPhongMaterial::setNormalIntensity(float newValue) {
    shaderData.setData(BlinnPhongMaterial::_normalIntensityProp, newValue);
}

float BlinnPhongMaterial::shininess() {
    return std::any_cast<float>(shaderData.getData(BlinnPhongMaterial::_shininessProp));
}

void BlinnPhongMaterial::setShininess(float newValue) {
    shaderData.setData(BlinnPhongMaterial::_shininessProp, newValue);
}

math::Float4 BlinnPhongMaterial::tilingOffset() {
    return std::any_cast<math::Float4>(shaderData.getData(BlinnPhongMaterial::_tilingOffsetProp));
}

void BlinnPhongMaterial::setTilingOffset(const math::Float4 &newValue) {
    shaderData.setData(BlinnPhongMaterial::_tilingOffsetProp, newValue);
}

BlinnPhongMaterial::BlinnPhongMaterial(Engine *engine) :
BaseMaterial(engine, Shader::find("blinn-phong")) {
    shaderData.enableMacro(NEED_WORLDPOS);
    shaderData.enableMacro(NEED_TILINGOFFSET);
    
    shaderData.setData(BlinnPhongMaterial::_diffuseColorProp, math::Color(1, 1, 1, 1));
    shaderData.setData(BlinnPhongMaterial::_specularColorProp, math::Color(1, 1, 1, 1));
    shaderData.setData(BlinnPhongMaterial::_emissiveColorProp, math::Color(0, 0, 0, 1));
    shaderData.setData(BlinnPhongMaterial::_tilingOffsetProp, math::Float4(1, 1, 0, 0));
    shaderData.setData(BlinnPhongMaterial::_shininessProp, 16.f);
    shaderData.setData(BlinnPhongMaterial::_normalIntensityProp, 1.f);
}

}
