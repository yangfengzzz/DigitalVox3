//
//  shader_data.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "shader_data.h"
#include "shader.h"

namespace vox {
std::any ShaderData::getData(const std::string& property_name) {
    auto property = Shader::getPropertyByName(property_name);
    if (property.has_value()) {
        return getData(property.value());
    } else {
        assert(false && "can't find property");
    }
}

std::any ShaderData::getData(const ShaderProperty& property) {
    return _properties[property._uniqueId];
}

void ShaderData::setData(const std::string& property_name, std::any value) {
    auto property = Shader::getPropertyByName(property_name);
    if (property.has_value()) {
        setData(property.value(), value);
    } else {
        assert(false && "can't find property");
    }
}

void ShaderData::setData(ShaderProperty property, std::any value) {
    _properties[property._uniqueId] = value;
}

void ShaderData::enableMacro(MacroName macroName) {
    _macroCollection._value.insert(std::make_pair(macroName, std::make_pair(1, MTLDataTypeBool)));
}

void ShaderData::enableMacro(MacroName macroName, std::pair<int, MTLDataType> value) {
    _macroCollection._value.insert(std::make_pair(macroName, value));
}

void ShaderData::disableMacro(MacroName macroName) {
    auto iter = _macroCollection._value.find(macroName);
    if (iter != _macroCollection._value.end()) {
        _macroCollection._value.erase(iter);
    }
}

}
