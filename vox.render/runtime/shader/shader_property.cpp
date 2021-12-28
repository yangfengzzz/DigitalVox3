//
//  shader_property.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "shader_property.h"

namespace vox {
int ShaderProperty::_propertyNameCounter = 0;

ShaderProperty::ShaderProperty(const std::string &name, ShaderDataGroup::Enum group) :
name(name),
group(group),
uniqueId(ShaderProperty::_propertyNameCounter) {
    ShaderProperty::_propertyNameCounter += 1;
}

}
