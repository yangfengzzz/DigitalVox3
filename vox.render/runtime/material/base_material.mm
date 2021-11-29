//
//  base_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "base_material.h"

namespace vox {
ShaderProperty BaseMaterial::_alphaCutoffProp = Shader::getPropertyByName("u_alphaCutoff");

bool BaseMaterial::isTransparent() {
    return _isTransparent;
}

void BaseMaterial::setIsTransparent(bool newValue) {
    
}

float BaseMaterial::alphaCutoff() {
    return std::any_cast<float>(shaderData.getData(BaseMaterial::_alphaCutoffProp));
}

void BaseMaterial::setAlphaCutoff(float newValue) {
    
}

const RenderFace& BaseMaterial::renderFace() {
    return _renderFace;
}

void BaseMaterial::setRenderFace(const RenderFace& newValue) {
    
}

const BlendMode& BaseMaterial::blendMode() {
    return _blendMode;
}

void BaseMaterial::setBlendMode(const BlendMode& newValue) {
    
}

BaseMaterial::BaseMaterial(Engine* engine, Shader* shader):
Material(engine, shader){
    shaderData.setData(BaseMaterial::_alphaCutoffProp, 0.0f);
}

}
