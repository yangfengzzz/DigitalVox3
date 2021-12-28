//
//  unlit_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "unlit_material.h"

namespace vox {
ShaderProperty UnlitMaterial::_baseColorProp = Shader::createProperty("u_baseColor", ShaderDataGroup::Material);
ShaderProperty UnlitMaterial::_baseTextureProp = Shader::createProperty("u_baseTexture", ShaderDataGroup::Material);
ShaderProperty UnlitMaterial::_tilingOffsetProp = Shader::createProperty("u_tilingOffset", ShaderDataGroup::Material);

math::Color UnlitMaterial::baseColor() {
    return std::any_cast<math::Color>(shaderData.getData(UnlitMaterial::_baseColorProp));
}

void UnlitMaterial::setBaseColor(const math::Color &newValue) {
    shaderData.setData(UnlitMaterial::_baseColorProp, newValue);
}

id <MTLTexture> UnlitMaterial::baseTexture() {
    return std::any_cast<id <MTLTexture>>(shaderData.getData(UnlitMaterial::_baseTextureProp));
}

void UnlitMaterial::setBaseTexture(id <MTLTexture> newValue) {
    shaderData.setData(UnlitMaterial::_baseTextureProp, newValue);
    
    if (newValue) {
        shaderData.enableMacro(HAS_BASE_TEXTURE);
    } else {
        shaderData.disableMacro(HAS_BASE_TEXTURE);
    }
}

math::Float4 UnlitMaterial::tilingOffset() {
    return std::any_cast<math::Float4>(shaderData.getData(UnlitMaterial::_tilingOffsetProp));
}

void UnlitMaterial::setTilingOffset(const math::Float4 &newValue) {
    shaderData.setData(UnlitMaterial::_tilingOffsetProp, newValue);
}

UnlitMaterial::UnlitMaterial(Engine *engine) :
BaseMaterial(engine, Shader::find("unlit")) {
    shaderData.enableMacro(OMIT_NORMAL);
    shaderData.enableMacro(NEED_TILINGOFFSET);
    
    shaderData.setData(UnlitMaterial::_baseColorProp, math::Color(1, 1, 1, 1));
    shaderData.setData(UnlitMaterial::_tilingOffsetProp, math::Float4(1, 1, 0, 0));
}

}
