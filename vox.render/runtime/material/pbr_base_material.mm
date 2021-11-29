//
//  pbr_base_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "pbr_base_material.h"

namespace vox {
ShaderProperty PBRBaseMaterial::_tilingOffsetProp = Shader::getPropertyByName("u_tilingOffset");
ShaderProperty PBRBaseMaterial::_normalTextureIntensityProp = Shader::getPropertyByName("u_normalIntensity");
ShaderProperty PBRBaseMaterial::_occlusionTextureIntensityProp = Shader::getPropertyByName("u_occlusionStrength");

ShaderProperty PBRBaseMaterial::_baseColorProp = Shader::getPropertyByName("u_baseColor");
ShaderProperty PBRBaseMaterial::_emissiveColorProp = Shader::getPropertyByName("u_emissiveColor");

ShaderProperty PBRBaseMaterial::_baseTextureProp = Shader::getPropertyByName("u_baseColorTexture");
ShaderProperty PBRBaseMaterial::_normalTextureProp = Shader::getPropertyByName("u_normalTexture");
ShaderProperty PBRBaseMaterial::_emissiveTextureProp = Shader::getPropertyByName("u_emissiveTexture");
ShaderProperty PBRBaseMaterial::_occlusionTextureProp = Shader::getPropertyByName("u_occlusionTexture");

math::Color PBRBaseMaterial::baseColor() {
    return std::any_cast<math::Color>(shaderData.getData(PBRBaseMaterial::_baseColorProp));
}

void PBRBaseMaterial::setBaseColor(const math::Color& newValue) {
    shaderData.setData(PBRBaseMaterial::_baseColorProp, newValue);
}

id<MTLTexture> PBRBaseMaterial::baseTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(PBRBaseMaterial::_baseTextureProp));
}

void PBRBaseMaterial::setBaseTexture(id<MTLTexture> newValue) {
    shaderData.setData(PBRBaseMaterial::_baseTextureProp, newValue);
}

id<MTLTexture> PBRBaseMaterial::normalTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(PBRBaseMaterial::_normalTextureProp));
}

void PBRBaseMaterial::setNormalTexture(id<MTLTexture> newValue) {
    shaderData.setData(PBRBaseMaterial::_normalTextureProp, newValue);
}

float PBRBaseMaterial::normalTextureIntensity() {
    return std::any_cast<float>(shaderData.getData(PBRBaseMaterial::_normalTextureIntensityProp));
}

void PBRBaseMaterial::setNormalTextureIntensity(float newValue) {
    shaderData.setData(PBRBaseMaterial::_normalTextureIntensityProp, newValue);
}

math::Color PBRBaseMaterial::emissiveColor() {
    return std::any_cast<math::Color>(shaderData.getData(PBRBaseMaterial::_emissiveColorProp));
}

void PBRBaseMaterial::setEmissiveColor(const math::Color& newValue) {
    shaderData.setData(PBRBaseMaterial::_emissiveColorProp, newValue);
}

id<MTLTexture> PBRBaseMaterial::emissiveTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(PBRBaseMaterial::_emissiveTextureProp));
}

void PBRBaseMaterial::setEmissiveTexture(id<MTLTexture> newValue) {
    shaderData.setData(PBRBaseMaterial::_emissiveTextureProp, newValue);
}

id<MTLTexture> PBRBaseMaterial::occlusionTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(PBRBaseMaterial::_occlusionTextureProp));
}

void PBRBaseMaterial::setOcclusionTexture(id<MTLTexture> newValue) {
    shaderData.setData(PBRBaseMaterial::_occlusionTextureProp, newValue);
}

float PBRBaseMaterial::occlusionTextureIntensity() {
    return std::any_cast<float>(shaderData.getData(PBRBaseMaterial::_occlusionTextureIntensityProp));
}

void PBRBaseMaterial::setOcclusionTextureIntensity(float newValue) {
    shaderData.setData(PBRBaseMaterial::_occlusionTextureIntensityProp, newValue);
}

math::Float4 PBRBaseMaterial::tilingOffset() {
    return std::any_cast<math::Float4>(shaderData.getData(PBRBaseMaterial::_tilingOffsetProp));
}

void PBRBaseMaterial::setTilingOffset(const math::Float4& newValue) {
    shaderData.setData(PBRBaseMaterial::_tilingOffsetProp, newValue);
}

PBRBaseMaterial::PBRBaseMaterial(Engine* engine):
BaseMaterial(engine, Shader::find("skin")){
    shaderData.enableMacro(NEED_WORLDPOS);
    shaderData.enableMacro(NEED_TILINGOFFSET);

    shaderData.setData(PBRBaseMaterial::_baseColorProp, math::Color(1, 1, 1, 1));
    shaderData.setData(PBRBaseMaterial::_emissiveColorProp, math::Color(0, 0, 0, 1));
    shaderData.setData(PBRBaseMaterial::_tilingOffsetProp, math::Float4(1, 1, 0, 0));

    shaderData.setData(PBRBaseMaterial::_normalTextureIntensityProp, 1.f);
    shaderData.setData(PBRBaseMaterial::_occlusionTextureIntensityProp, 1.f);
}

}
