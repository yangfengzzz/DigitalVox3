//
//  pbr_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "pbr_material.h"

namespace vox {
ShaderProperty PBRMaterial::_metallicProp = Shader::getPropertyByName("u_metal");
ShaderProperty PBRMaterial::_roughnessProp = Shader::getPropertyByName("u_roughness");
ShaderProperty PBRMaterial::_metallicTextureProp = Shader::getPropertyByName("u_metallicTexture");
ShaderProperty PBRMaterial::_roughnessTextureProp = Shader::getPropertyByName("u_roughnessTexture");

float PBRMaterial::metallic(){
    return std::any_cast<float>(shaderData.getData(PBRMaterial::_metallicProp));
}

void PBRMaterial::setMetallic(float newValue){
    shaderData.setData(PBRMaterial::_metallicProp, newValue);
}

float PBRMaterial::roughness(){
    return std::any_cast<float>(shaderData.getData(PBRMaterial::_roughnessProp));
}

void PBRMaterial::setRoughness(float newValue){
    shaderData.setData(PBRMaterial::_roughnessProp, newValue);
}

id<MTLTexture> PBRMaterial::roughnessTexture(){
    return std::any_cast<id<MTLTexture>>(shaderData.getData(PBRMaterial::_roughnessTextureProp));
}

void PBRMaterial::setRoughnessTexture(id<MTLTexture> newValue){
    shaderData.setData(PBRMaterial::_roughnessTextureProp, newValue);
}

id<MTLTexture> PBRMaterial::metallicTexture(){
    return std::any_cast<id<MTLTexture>>(shaderData.getData(PBRMaterial::_roughnessTextureProp));
}

void PBRMaterial::setMetallicTexture(id<MTLTexture> newValue){
    shaderData.setData(PBRMaterial::_roughnessTextureProp, newValue);
}

PBRMaterial::PBRMaterial(Engine* engine):
PBRBaseMaterial(engine){
    shaderData.enableMacro(IS_METALLIC_WORKFLOW);
    shaderData.setData(PBRMaterial::_metallicProp, 1.f);
    shaderData.setData(PBRMaterial::_roughnessProp, 1.f);
}

}
