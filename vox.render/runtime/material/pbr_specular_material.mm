//
//  pbr_specular_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "pbr_specular_material.h"

namespace vox {
ShaderProperty PBRSpecularMaterial::_glossinessProp = Shader::getPropertyByName("u_glossinessFactor");
ShaderProperty PBRSpecularMaterial::_specularColorProp = Shader::getPropertyByName("u_specularColor");
ShaderProperty PBRSpecularMaterial::_glossinessTextureProp = Shader::getPropertyByName("u_glossinessTexture");
ShaderProperty PBRSpecularMaterial::_specularTextureProp = Shader::getPropertyByName("u_specularTexture");

Color PBRSpecularMaterial::specularColor() {
    return std::any_cast<Color>(shaderData.getData(PBRSpecularMaterial::_specularColorProp));
}

void PBRSpecularMaterial::setSpecularColor(const Color& newValue) {
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
}

id<MTLTexture> PBRSpecularMaterial::specularTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(PBRSpecularMaterial::_specularTextureProp));
}

void PBRSpecularMaterial::setSpecularTexture(id<MTLTexture> newValue) {
    shaderData.setData(PBRSpecularMaterial::_specularTextureProp, newValue);
}

PBRSpecularMaterial::PBRSpecularMaterial(Engine* engine):
PBRBaseMaterial(engine){
    shaderData.setData(PBRSpecularMaterial::_specularColorProp, Color(1, 1, 1, 1));
    shaderData.setData(PBRSpecularMaterial::_glossinessProp, 1.f);
}

}
