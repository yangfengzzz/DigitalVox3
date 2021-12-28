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
ShaderProperty PBRSpecularMaterial::_specularGlossinessTextureProp = Shader::createProperty("_specularGlossinessTexture", ShaderDataGroup::Material);

math::Color PBRSpecularMaterial::specularColor() {
    return std::any_cast<math::Color>(shaderData.getData(PBRSpecularMaterial::_specularColorProp));
}

void PBRSpecularMaterial::setSpecularColor(const math::Color &newValue) {
    shaderData.setData(PBRSpecularMaterial::_specularColorProp, newValue);
}

float PBRSpecularMaterial::glossiness() {
    return std::any_cast<float>(shaderData.getData(PBRSpecularMaterial::_glossinessProp));
}

void PBRSpecularMaterial::setGlossiness(float newValue) {
    shaderData.setData(PBRSpecularMaterial::_glossinessProp, newValue);
}

id <MTLTexture> PBRSpecularMaterial::specularGlossinessTexture() {
    return std::any_cast<id <MTLTexture>>(shaderData.getData(PBRSpecularMaterial::_specularGlossinessTextureProp));
}

void PBRSpecularMaterial::setSpecularGlossinessTexture(id <MTLTexture> newValue) {
    shaderData.setData(PBRSpecularMaterial::_specularGlossinessTextureProp, newValue);
    if (newValue) {
        shaderData.enableMacro(HAS_SPECULARGLOSSINESSMAP);
    } else {
        shaderData.disableMacro(HAS_SPECULARGLOSSINESSMAP);
    }
}

PBRSpecularMaterial::PBRSpecularMaterial(Engine *engine) :
PBRBaseMaterial(engine) {
    shaderData.setData(PBRSpecularMaterial::_specularColorProp, math::Color(1, 1, 1, 1));
    shaderData.setData(PBRSpecularMaterial::_glossinessProp, 1.f);
}

}
