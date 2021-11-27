//
//  shader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "shader.h"
#include "log.h"

namespace vox {
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

ShaderProperty Shader::getPropertyByName(const std::string& name) {
    auto iter = Shader::_propertyNameMap.find(name);
    if (iter != Shader::_propertyNameMap.end()) {
        return iter->second;
    } else {
        auto property = ShaderProperty(name);
        Shader::_propertyNameMap.insert(std::make_pair(name, property));
        return property;
    }
}

std::optional<ShaderDataGroup> Shader::_getShaderPropertyGroup(const std::string& propertyName) {
    auto iter = Shader::_propertyNameMap.find(propertyName);
    if (iter != Shader::_propertyNameMap.end()) {
        return iter->second._group;
    } else {
        return std::nullopt;
    }
}

//ShaderProgram Shader::_getShaderProgram(EnginePtr engine, ShaderMacroCollection macroCollection) {
//
//}

}
