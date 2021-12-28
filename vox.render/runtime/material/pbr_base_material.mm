//
//  pbr_base_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "pbr_base_material.h"

namespace vox {
ShaderProperty PBRBaseMaterial::_tilingOffsetProp = Shader::createProperty("u_tilingOffset", ShaderDataGroup::Material);
ShaderProperty PBRBaseMaterial::_normalTextureIntensityProp = Shader::createProperty("u_normalIntensity", ShaderDataGroup::Material);
ShaderProperty PBRBaseMaterial::_occlusionTextureIntensityProp = Shader::createProperty("u_occlusionStrength", ShaderDataGroup::Material);

ShaderProperty PBRBaseMaterial::_baseColorProp = Shader::createProperty("u_baseColor", ShaderDataGroup::Material);
ShaderProperty PBRBaseMaterial::_emissiveColorProp = Shader::createProperty("u_emissiveColor", ShaderDataGroup::Material);

ShaderProperty PBRBaseMaterial::_baseTextureProp = Shader::createProperty("u_baseColorTexture", ShaderDataGroup::Material);
ShaderProperty PBRBaseMaterial::_normalTextureProp = Shader::createProperty("u_normalTexture", ShaderDataGroup::Material);
ShaderProperty PBRBaseMaterial::_emissiveTextureProp = Shader::createProperty("u_emissiveTexture", ShaderDataGroup::Material);
ShaderProperty PBRBaseMaterial::_occlusionTextureProp = Shader::createProperty("u_occlusionTexture", ShaderDataGroup::Material);

math::Color PBRBaseMaterial::baseColor() {
    return std::any_cast<math::Color>(shaderData.getData(PBRBaseMaterial::_baseColorProp));
}

void PBRBaseMaterial::setBaseColor(const math::Color &newValue) {
    shaderData.setData(PBRBaseMaterial::_baseColorProp, newValue);
}

id <MTLTexture> PBRBaseMaterial::baseTexture() {
    return std::any_cast<id <MTLTexture>>(shaderData.getData(PBRBaseMaterial::_baseTextureProp));
}

void PBRBaseMaterial::setBaseTexture(id <MTLTexture> newValue) {
    shaderData.setData(PBRBaseMaterial::_baseTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_BASE_COLORMAP);
    } else {
        shaderData.disableMacro(HAS_BASE_COLORMAP);
    }
}

id <MTLTexture> PBRBaseMaterial::normalTexture() {
    return std::any_cast<id <MTLTexture>>(shaderData.getData(PBRBaseMaterial::_normalTextureProp));
}

void PBRBaseMaterial::setNormalTexture(id <MTLTexture> newValue) {
    shaderData.setData(PBRBaseMaterial::_normalTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_NORMAL_TEXTURE);
    } else {
        shaderData.disableMacro(HAS_NORMAL_TEXTURE);
    }
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

void PBRBaseMaterial::setEmissiveColor(const math::Color &newValue) {
    shaderData.setData(PBRBaseMaterial::_emissiveColorProp, newValue);
}

id <MTLTexture> PBRBaseMaterial::emissiveTexture() {
    return std::any_cast<id <MTLTexture>>(shaderData.getData(PBRBaseMaterial::_emissiveTextureProp));
}

void PBRBaseMaterial::setEmissiveTexture(id <MTLTexture> newValue) {
    shaderData.setData(PBRBaseMaterial::_emissiveTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_EMISSIVEMAP);
    } else {
        shaderData.disableMacro(HAS_EMISSIVEMAP);
    }
}

id <MTLTexture> PBRBaseMaterial::occlusionTexture() {
    return std::any_cast<id <MTLTexture>>(shaderData.getData(PBRBaseMaterial::_occlusionTextureProp));
}

void PBRBaseMaterial::setOcclusionTexture(id <MTLTexture> newValue) {
    shaderData.setData(PBRBaseMaterial::_occlusionTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_OCCLUSIONMAP);
    } else {
        shaderData.disableMacro(HAS_OCCLUSIONMAP);
    }
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

void PBRBaseMaterial::setTilingOffset(const math::Float4 &newValue) {
    shaderData.setData(PBRBaseMaterial::_tilingOffsetProp, newValue);
}

PBRBaseMaterial::PBRBaseMaterial(Engine *engine) :
BaseMaterial(engine, Shader::find("pbr")) {
    shaderData.enableMacro(NEED_WORLDPOS);
    shaderData.enableMacro(NEED_TILINGOFFSET);
    
    shaderData.setData(PBRBaseMaterial::_baseColorProp, math::Color(1, 1, 1, 1));
    shaderData.setData(PBRBaseMaterial::_emissiveColorProp, math::Color(0, 0, 0, 1));
    shaderData.setData(PBRBaseMaterial::_tilingOffsetProp, math::Float4(1, 1, 0, 0));
    
    shaderData.setData(PBRBaseMaterial::_normalTextureIntensityProp, 1.f);
    shaderData.setData(PBRBaseMaterial::_occlusionTextureIntensityProp, 1.f);
}

}
