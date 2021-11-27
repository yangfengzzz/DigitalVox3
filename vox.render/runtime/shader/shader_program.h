//
//  shader_program.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef shader_program_hpp
#define shader_program_hpp

#import <Metal/Metal.h>

namespace vox {
/// Shader program, corresponding to the GPU shader program.
class ShaderProgram {
public:
    
private:
    static int _counter;
    int ID;
    bool _isValid;
    id<MTLLibrary> _library;
    id<MTLFunction> _vertexShader;
    id<MTLFunction> _fragmentShader;
};

}

#endif /* shader_program_hpp */
