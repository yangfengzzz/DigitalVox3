//
//  unlit_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "unlit_material.h"

namespace vox {
ShaderProperty UnlitMaterial::_baseColorProp = Shader::getPropertyByName("u_baseColor");
ShaderProperty UnlitMaterial::_baseTextureProp = Shader::getPropertyByName("u_baseTexture");
ShaderProperty UnlitMaterial::_tilingOffsetProp = Shader::getPropertyByName("u_tilingOffset");

Color UnlitMaterial::baseColor() {
    return std::any_cast<Color>(shaderData.getData(UnlitMaterial::_baseColorProp));
}

void UnlitMaterial::setBaseColor(const Color& newValue) {
    shaderData.setData(UnlitMaterial::_baseColorProp, newValue);
}

id<MTLTexture> UnlitMaterial::baseTexture() {
    return std::any_cast<id<MTLTexture>>(shaderData.getData(UnlitMaterial::_baseTextureProp));
}

void UnlitMaterial::setBaseTexture(id<MTLTexture> newValue) {
    shaderData.setData(UnlitMaterial::_baseTextureProp, newValue);
}

Float4 UnlitMaterial::tilingOffset() {
    return std::any_cast<Float4>(shaderData.getData(UnlitMaterial::_tilingOffsetProp));
}

void UnlitMaterial::setTilingOffset(const Float4& newValue) {
    shaderData.setData(UnlitMaterial::_tilingOffsetProp, newValue);
}

UnlitMaterial::UnlitMaterial(Engine* engine):
BaseMaterial(engine, Shader::find("unlit")){
    shaderData.enableMacro(OMIT_NORMAL);
    shaderData.enableMacro(NEED_TILINGOFFSET);

    shaderData.setData(UnlitMaterial::_baseColorProp, Color(1, 1, 1, 1));
    shaderData.setData(UnlitMaterial::_tilingOffsetProp, Float4(1, 1, 0, 0));
}

}
