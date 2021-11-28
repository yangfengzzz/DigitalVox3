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
    std::any getData(const std::string& property_name);

    std::any getData(const ShaderProperty& property);

    void setData(const std::string& property, std::any value);
    
    void setData(ShaderProperty property, std::any value);
    
    /// Enable macro.
    /// - Parameter macroName: Macro name
    void enableMacro(MacroName macroName);

    /// Enable macro.
    /// - Parameters:
    ///   - name: Macro name
    ///   - value: Macro value
    void enableMacro(MacroName macroName, std::pair<int, MTLDataType> value);

    /// Disable macro
    /// - Parameter macroName: Macro name
    void disableMacro(MacroName macroName);
    
private:
    friend class Camera;
    friend class Material;
    friend class Renderer;
    friend class Scene;
    friend class ComponentsManager;
    friend class RenderPipelineState;
    
    ShaderData(ShaderDataGroup group);
    
    ShaderDataGroup _group;
    std::unordered_map<int, std::any> _properties;
    ShaderMacroCollection _macroCollection;
    int _refCount;
};

}
#endif /* shader_data_hpp */
