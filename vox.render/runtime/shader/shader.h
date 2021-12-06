//
//  shader.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef shader_hpp
#define shader_hpp

#include <unordered_map>
#include <string>
#include <optional>
#include "../vox_type.h"
#include "shader_property.h"
#include "shader_program.h"
#include "shader_macro_collection.h"

namespace vox {
/// Shader containing vertex and fragment source.
class Shader {
public:
    /// The name of shader.
    std::string name;
    
    Shader(const std::string& name, const std::string& vertexSource, const std::string& fragmentSource);
    
    /// Create a shader.
    /// - Parameters:    Shader(const std::string& name, const std::string& vertexSource, const std::string& fragmentSource);

    ///   - name: Name of the shader
    ///   - vertexSource: Vertex source code
    ///   - fragmentSource: Fragment source code
    /// - Returns: Shader
    static Shader* create(const std::string& name, const std::string& vertexSource, const std::string& fragmentSource);
    
    
    /// Find a shader by name.
    /// - Parameter name: Name of the shader
    /// - Returns: Shader
    static Shader* find(const std::string& name);
    
    /// Get shader property by name.
    /// - Parameter name: Name of the shader property
    /// - Returns: Shader property
    static std::optional<ShaderProperty> getPropertyByName(const std::string& name);
    
    /// Get shader property by name.
    /// - Parameter name: Name of the shader property
    /// - Returns: Shader property
    static ShaderProperty createProperty(const std::string& name, ShaderDataGroup::Enum group);
    
private:
    friend class RenderPipelineState;
    friend class RenderQueue;
    
    static std::unordered_map<std::string, std::unique_ptr<Shader>> _shaderMap;
    static std::unordered_map<std::string, ShaderProperty> _propertyNameMap;
    
    static std::optional<ShaderDataGroup::Enum> _getShaderPropertyGroup(const std::string& propertyName);
    
    ShaderProgram* _getShaderProgram(Engine* engine, const ShaderMacroCollection& macroCollection);

    int _shaderId = 0;
    std::string _vertexSource;
    std::string _fragmentSource;
};

}

#endif /* shader_hpp */
