//
//  shader_uniform.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef shader_uniform_hpp
#define shader_uniform_hpp

#include <Metal/Metal.h>
#include <string>
#include <vector>

namespace vox {
/// Shader uniform。
class ShaderUniform {
public:
    std::string name;
    int propertyId;
    size_t location;
};

/// Shader uniform block.
class ShaderUniformBlock {
public:
    std::vector<ShaderUniform> constUniforms;
    std::vector<ShaderUniform> textureUniforms;
};

}

#endif /* shader_uniform_hpp */
