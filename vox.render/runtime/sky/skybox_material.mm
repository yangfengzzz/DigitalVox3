//
//  skybox_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/17.
//

#include "skybox_material.h"

namespace vox {
ShaderProperty SkyBoxMaterial::_skyboxTextureProp = Shader::createProperty("u_skybox", ShaderDataGroup::Enum::Material);
ShaderProperty SkyBoxMaterial::_mvpNoscaleProp = Shader::createProperty("u_mvpNoscale", ShaderDataGroup::Enum::Material);

bool SkyBoxMaterial::textureDecodeRGBM() {
    return _decodeParam.x;
}

void SkyBoxMaterial::setTextureDecodeRGBM(bool value) {
    _decodeParam.x = float(value);
}

float SkyBoxMaterial::RGBMDecodeFactor() {
    return _decodeParam.y;
}

void SkyBoxMaterial::setRGBMDecodeFactor(float value) {
    _decodeParam.y = value;
}
    
id<MTLTexture> SkyBoxMaterial::textureCubeMap() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(SkyBoxMaterial::_skyboxTextureProp));
}

void SkyBoxMaterial::setTextureCubeMap(id<MTLTexture> v) {
    shaderData.setData(SkyBoxMaterial::_skyboxTextureProp, v);
}

SkyBoxMaterial::SkyBoxMaterial(Engine* engine):
Material(engine, Shader::find("skybox")) {
    renderState.rasterState.cullMode = MTLCullModeBack;
    renderState.depthState.compareFunction = MTLCompareFunctionLessEqual;
}

}
