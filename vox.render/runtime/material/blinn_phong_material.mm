//
//  blinn_phong_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "blinn_phong_material.h"

namespace vox {
ShaderProperty BlinnPhongMaterial::_diffuseColorProp = Shader::getPropertyByName("u_diffuseColor");
ShaderProperty BlinnPhongMaterial::_specularColorProp = Shader::getPropertyByName("u_specularColor");
ShaderProperty BlinnPhongMaterial::_emissiveColorProp = Shader::getPropertyByName("u_emissiveColor");
ShaderProperty BlinnPhongMaterial::_tilingOffsetProp = Shader::getPropertyByName("u_tilingOffset");
ShaderProperty BlinnPhongMaterial::_shininessProp = Shader::getPropertyByName("u_shininess");
ShaderProperty BlinnPhongMaterial::_normalIntensityProp = Shader::getPropertyByName("u_normalIntensity");

ShaderProperty BlinnPhongMaterial::_baseTextureProp = Shader::getPropertyByName("u_diffuseTexture");
ShaderProperty BlinnPhongMaterial::_specularTextureProp = Shader::getPropertyByName("u_specularTexture");
ShaderProperty BlinnPhongMaterial::_emissiveTextureProp = Shader::getPropertyByName("u_emissiveTexture");
ShaderProperty BlinnPhongMaterial::_normalTextureProp = Shader::getPropertyByName("u_normalTexture");

Color BlinnPhongMaterial::baseColor() {
    return std::any_cast<Color>(shaderData.getData(BlinnPhongMaterial::_diffuseColorProp));
}

void BlinnPhongMaterial::setBaseColor(const Color& newValue) {
    shaderData.setData(BlinnPhongMaterial::_diffuseColorProp, newValue);
}

id<MTLTexture> BlinnPhongMaterial::baseTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(BlinnPhongMaterial::_baseTextureProp));
}

void BlinnPhongMaterial::setBaseTexture(id<MTLTexture> newValue) {
    shaderData.setData(BlinnPhongMaterial::_baseTextureProp, newValue);
}

Color BlinnPhongMaterial::specularColor() {
    return std::any_cast<Color>(shaderData.getData(BlinnPhongMaterial::_specularColorProp));
}

void BlinnPhongMaterial::setSpecularColor(const Color& newValue) {
    shaderData.setData(BlinnPhongMaterial::_specularColorProp, newValue);
}

id<MTLTexture> BlinnPhongMaterial::specularTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(BlinnPhongMaterial::_specularTextureProp));
}

void BlinnPhongMaterial::setSpecularTexture(id<MTLTexture> newValue) {
    shaderData.setData(BlinnPhongMaterial::_specularTextureProp, newValue);
}

Color BlinnPhongMaterial::emissiveColor() {
    return std::any_cast<Color>(shaderData.getData(BlinnPhongMaterial::_emissiveColorProp));
}

void BlinnPhongMaterial::setEmissiveColor(const Color& newValue) {
    shaderData.setData(BlinnPhongMaterial::_emissiveColorProp, newValue);
}

id<MTLTexture> BlinnPhongMaterial::emissiveTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(BlinnPhongMaterial::_emissiveTextureProp));
}

void BlinnPhongMaterial::BlinnPhongMaterial::setEmissiveTexture(id<MTLTexture> newValue) {
    shaderData.setData(BlinnPhongMaterial::_emissiveTextureProp, newValue);
}

id<MTLTexture> BlinnPhongMaterial::normalTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(BlinnPhongMaterial::_normalTextureProp));
}

void BlinnPhongMaterial::setNormalTexture(id<MTLTexture> newValue) {
    shaderData.setData(BlinnPhongMaterial::_normalTextureProp, newValue);
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

Float4 BlinnPhongMaterial::tilingOffset() {
    return std::any_cast<Float4>(shaderData.getData(BlinnPhongMaterial::_tilingOffsetProp));
}

void BlinnPhongMaterial::setTilingOffset(const Float4& newValue) {
    shaderData.setData(BlinnPhongMaterial::_tilingOffsetProp, newValue);
}

BlinnPhongMaterial::BlinnPhongMaterial(Engine* engine):
BaseMaterial(engine, Shader::find("blinn-phong")){
    shaderData.enableMacro(NEED_WORLDPOS);
    shaderData.enableMacro(NEED_TILINGOFFSET);

    shaderData.setData(BlinnPhongMaterial::_diffuseColorProp, Color(1, 1, 1, 1));
    shaderData.setData(BlinnPhongMaterial::_specularColorProp, Color(1, 1, 1, 1));
    shaderData.setData(BlinnPhongMaterial::_emissiveColorProp, Color(0, 0, 0, 1));
    shaderData.setData(BlinnPhongMaterial::_tilingOffsetProp, Float4(1, 1, 0, 0));
    shaderData.setData(BlinnPhongMaterial::_shininessProp, 16.f);
    shaderData.setData(BlinnPhongMaterial::_normalIntensityProp, 1.f);
}

}
