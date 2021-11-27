//
//  shader_data.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "shader_data.h"
#include "shader.h"

namespace vox {
ShaderData::ShaderData(ShaderDataGroup group) {
    _group = group;
}

std::any ShaderData::_getData(const std::string& property_name) {
    auto property = Shader::getPropertyByName(property_name);
    return _getData(property);
}

std::any ShaderData::_getData(const ShaderProperty& property) {
    return _properties[property._uniqueId];
}

void ShaderData::_setData(const std::string& property_name, std::any value) {
    auto property = Shader::getPropertyByName(property_name);
    _setData(property, value);
}

void ShaderData::_setData(ShaderProperty property, std::any value) {
    _properties.insert(std::make_pair(property._uniqueId, value));
}


}
