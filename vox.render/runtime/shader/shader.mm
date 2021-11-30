//
//  shader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "shader.h"
#include "log.h"
#include "../engine.h"

namespace vox {
std::unordered_map<std::string, std::unique_ptr<Shader>> Shader::_shaderMap = {};
std::unordered_map<std::string, ShaderProperty> Shader::_propertyNameMap = {};

Shader::Shader(const std::string& name,
               const std::string& vertexSource,
               const std::string& fragmentSource):
name(name),
_vertexSource(vertexSource),
_fragmentSource(fragmentSource){
}

Shader* Shader::create(const std::string& name,
                      const std::string& vertexSource,
                      const std::string& fragmentSource) {
    auto iter = Shader::_shaderMap.find(name);
    
    if (iter != Shader::_shaderMap.end()) {
        log::Err() << ("Shader named" + name + "already exists.") << std::endl;
    }
    auto shader = std::make_unique<Shader>(name, vertexSource, fragmentSource);
    auto shaderPtr = shader.get();
    Shader::_shaderMap.insert(std::make_pair(name, std::move(shader)));
    return shaderPtr;
}

Shader* Shader::find(const std::string& name) {
    auto iter = Shader::_shaderMap.find(name);
    if (iter != Shader::_shaderMap.end()) {
        return iter->second.get();
    } else {
        return nullptr;
    }
}

std::optional<ShaderProperty> Shader::getPropertyByName(const std::string& name) {
    auto iter = Shader::_propertyNameMap.find(name);
    if (iter != Shader::_propertyNameMap.end()) {
        return iter->second;
    } else {
        return std::nullopt;
    }
}

ShaderProperty Shader::createProperty(const std::string& name, ShaderDataGroup group) {
    auto property = ShaderProperty(name, group);
    Shader::_propertyNameMap.insert(std::make_pair(name, property));
    return property;
}

std::optional<ShaderDataGroup> Shader::_getShaderPropertyGroup(const std::string& propertyName) {
    auto iter = Shader::_propertyNameMap.find(propertyName);
    if (iter != Shader::_propertyNameMap.end()) {
        return iter->second._group;
    } else {
        return std::nullopt;
    }
}

ShaderProgram* Shader::_getShaderProgram(Engine* engine, const ShaderMacroCollection& macroCollection) {
    return engine->_hardwareRenderer.resouceCache.request_shader_module(_vertexSource, _fragmentSource, macroCollection);
}

}
