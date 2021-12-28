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
/**
 * Shader containing vertex and fragment source.
 */
class Shader {
public:
    /** The name of shader. */
    std::string name;
    
    Shader(const std::string &name, const std::string &vertexSource,
           const std::string &fragmentSource, const std::string &deferredFragmentSource = "");
    
    ShaderProgram *findShaderProgram(Engine *engine, const ShaderMacroCollection &macroCollection, bool isDeferred = false);
    
    /**
     * Create a shader.
     * @param name - Name of the shader
     * @param vertexSource - Vertex source code
     * @param fragmentSource - Fragment source code
     */
    static Shader *create(const std::string &name, const std::string &vertexSource,
                          const std::string &fragmentSource, const std::string &deferredFragmentSource = "");
    
    /**
     * Find a shader by name.
     * @param name - Name of the shader
     */
    static Shader *find(const std::string &name);
    
public:
    /**
     * Get shader property by name.
     * @param name - Name of the shader property
     * @returns Shader property
     */
    static std::optional<ShaderProperty> getPropertyByName(const std::string &name);
    
    static std::optional<ShaderDataGroup::Enum> getShaderPropertyGroup(const std::string &propertyName);
    
    /**
     * Create shader property by name.
     * @param name - Name of the shader property
     * @param group - Group of shader data
     * @returns Shader property
     */
    static ShaderProperty createProperty(const std::string &name, ShaderDataGroup::Enum group);
    
private:
    // common shader map
    static std::unordered_map<std::string, std::unique_ptr<Shader>> _shaderMap;
    static std::unordered_map<std::string, ShaderProperty> _propertyNameMap;
    
    // object shader data
    int _shaderId = 0;
    std::string _vertexSource;
    std::string _fragmentSource;
    std::string _deferredFragmentSource;
};

}

#endif /* shader_hpp */
