//
//  shader_property.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef shader_property_hpp
#define shader_property_hpp

#include "enums/shaderData_group.h"
#include <string>

namespace vox {
/// Shader property.
struct ShaderProperty {
    /// Shader property name.
    std::string name;
    
private:
    friend class ShaderData;
    
    static int _propertyNameCounter;
    int _uniqueId;
    ShaderDataGroup _group;

    ShaderProperty(const std::string& name);
};

}
#endif /* shader_property_hpp */
