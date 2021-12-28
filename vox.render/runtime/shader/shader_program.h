//
//  shader_program.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef shader_program_hpp
#define shader_program_hpp

#import <Metal/Metal.h>
#include "shader_macro_collection.h"

namespace vox {
/**
 * Shader program, corresponding to the GPU shader program.
 */
class ShaderProgram {
public:
    id <MTLFunction> vertexShader();
    
    id <MTLFunction> fragmentShader();
    
    /**
     * Whether this shader program is valid.
     */
    bool isValid();
    
    ShaderProgram(id <MTLLibrary> library, const std::string &vertexSource, const std::string &fragmentSource,
                  const ShaderMacroCollection &macroInfo);
    
    
private:
    MTLFunctionConstantValues *makeFunctionConstants(const ShaderMacroCollection &macroInfo);
    
    /**
     * init and link program with shader.
     */
    void _createProgram(const std::string &vertexSource, const std::string &fragmentSource,
                        const ShaderMacroCollection &macroInfo);
    
    static int _counter;
    int ID;
    bool _isValid;
    id <MTLLibrary> _library;
    id <MTLFunction> _vertexShader;
    id <MTLFunction> _fragmentShader;
};

}

#endif /* shader_program_hpp */
