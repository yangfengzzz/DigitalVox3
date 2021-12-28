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

Shader::Shader(const std::string &name,
               const std::string &vertexSource,
               const std::string &fragmentSource,
               const std::string &deferredFragmentSource) :
name(name),
_vertexSource(vertexSource),
_fragmentSource(fragmentSource),
_deferredFragmentSource(deferredFragmentSource) {
}

ShaderProgram *Shader::findShaderProgram(Engine *engine, const ShaderMacroCollection &macroCollection, bool isDeferred) {
    if (isDeferred) {
        return engine->_hardwareRenderer.resouceCache.request_shader_module(_vertexSource, _deferredFragmentSource, macroCollection);
    } else {
        return engine->_hardwareRenderer.resouceCache.request_shader_module(_vertexSource, _fragmentSource, macroCollection);
    }
}

Shader *Shader::create(const std::string &name,
                       const std::string &vertexSource,
                       const std::string &fragmentSource,
                       const std::string &deferredFragmentSource) {
    auto iter = Shader::_shaderMap.find(name);
    
    if (iter != Shader::_shaderMap.end()) {
        log::Err() << ("Shader named" + name + "already exists.") << std::endl;
    }
    auto shader = std::make_unique<Shader>(name, vertexSource, fragmentSource, deferredFragmentSource);
    auto shaderPtr = shader.get();
    Shader::_shaderMap.insert(std::make_pair(name, std::move(shader)));
    return shaderPtr;
}

Shader *Shader::find(const std::string &name) {
    auto iter = Shader::_shaderMap.find(name);
    if (iter != Shader::_shaderMap.end()) {
        return iter->second.get();
    } else {
        return nullptr;
    }
}

//MARK: - Property
std::optional<ShaderProperty> Shader::getPropertyByName(const std::string &name) {
    auto iter = Shader::_propertyNameMap.find(name);
    if (iter != Shader::_propertyNameMap.end()) {
        return iter->second;
    } else {
        return std::nullopt;
    }
}

ShaderProperty Shader::createProperty(const std::string &name, ShaderDataGroup::Enum group) {
    auto iter = Shader::_propertyNameMap.find(name);
    if (iter != Shader::_propertyNameMap.end()) {
        return iter->second;
    } else {
        auto property = ShaderProperty(name, group);
        Shader::_propertyNameMap.insert(std::make_pair(name, property));
        return property;
    }
}

std::optional<ShaderDataGroup::Enum> Shader::getShaderPropertyGroup(const std::string &propertyName) {
    auto iter = Shader::_propertyNameMap.find(propertyName);
    if (iter != Shader::_propertyNameMap.end()) {
        return iter->second.group;
    } else {
        return std::nullopt;
    }
}

}
