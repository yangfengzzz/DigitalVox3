//
//  shader_data.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef shader_data_hpp
#define shader_data_hpp

#include "enums/shaderData_group.h"
#include "shader_macro_collection.h"
#include "shader_property.h"
#include <any>
#include <unordered_map>

namespace vox {
class MetalRenderer;

///  Shader data collection,Correspondence includes shader properties data and macros data.
class ShaderData {
public:
    
    
private:
    ShaderData(ShaderDataGroup group);

    std::any _getData(const std::string& property_name);

    std::any _getData(const ShaderProperty& property);

    void _setData(const std::string& property, std::any value);
    
    void _setData(ShaderProperty property, std::any value);
    
    ShaderDataGroup _group;
    std::unordered_map<int, std::any> _properties;
    ShaderMacroCollection _macroCollection;
    int _refCount;
};

}
#endif /* shader_data_hpp */
