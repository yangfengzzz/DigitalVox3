//
//  pbr_specular_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "pbr_specular_material.h"

namespace vox {
ShaderProperty PBRSpecularMaterial::_glossinessProp = Shader::createProperty("u_glossiness", ShaderDataGroup::Material);
ShaderProperty PBRSpecularMaterial::_specularColorProp = Shader::createProperty("u_specularColor", ShaderDataGroup::Material);
ShaderProperty PBRSpecularMaterial::_glossinessTextureProp = Shader::createProperty("u_glossinessTexture", ShaderDataGroup::Material);
ShaderProperty PBRSpecularMaterial::_specularTextureProp = Shader::createProperty("u_specularTexture", ShaderDataGroup::Material);

math::Color PBRSpecularMaterial::specularColor() {
    return std::any_cast<math::Color>(shaderData.getData(PBRSpecularMaterial::_specularColorProp));
}

void PBRSpecularMaterial::setSpecularColor(const math::Color& newValue) {
    shaderData.setData(PBRSpecularMaterial::_specularColorProp, newValue);
}

float PBRSpecularMaterial::glossiness() {
    return std::any_cast<float>(shaderData.getData(PBRSpecularMaterial::_glossinessProp));
}

void PBRSpecularMaterial::setGlossiness(float newValue) {
    shaderData.setData(PBRSpecularMaterial::_glossinessProp, newValue);
}

id<MTLTexture> PBRSpecularMaterial::glossinessTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(PBRSpecularMaterial::_glossinessTextureProp));
}

void PBRSpecularMaterial::setGlossinessTexture(id<MTLTexture> newValue) {
    shaderData.setData(PBRSpecularMaterial::_glossinessTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_GLOSSINESSMAP);
    } else {
        shaderData.disableMacro(HAS_GLOSSINESSMAP);
    }
}

id<MTLTexture> PBRSpecularMaterial::specularTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(PBRSpecularMaterial::_specularTextureProp));
}

void PBRSpecularMaterial::setSpecularTexture(id<MTLTexture> newValue) {
    shaderData.setData(PBRSpecularMaterial::_specularTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_SPECULARMAP);
    } else {
        shaderData.disableMacro(HAS_SPECULARMAP);
    }
}

PBRSpecularMaterial::PBRSpecularMaterial(Engine* engine):
PBRBaseMaterial(engine){
    shaderData.setData(PBRSpecularMaterial::_specularColorProp, math::Color(1, 1, 1, 1));
    shaderData.setData(PBRSpecularMaterial::_glossinessProp, 1.f);
}

}
