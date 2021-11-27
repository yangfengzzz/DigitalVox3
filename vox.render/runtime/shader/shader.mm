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


}
