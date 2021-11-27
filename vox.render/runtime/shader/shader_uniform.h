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

namespace vox {
/// Shader uniform。
class ShaderUniform {
public:
    std::string name;
    int propertyId;
    int location;
};

}

#endif /* shader_uniform_hpp */
