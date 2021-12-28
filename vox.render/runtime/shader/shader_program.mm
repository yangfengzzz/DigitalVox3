//
//  shader_program.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "shader_program.h"
#include <string>

namespace vox {
int ShaderProgram::_counter = 0;

id <MTLFunction> ShaderProgram::vertexShader() {
    return _vertexShader;
}

id <MTLFunction> ShaderProgram::fragmentShader() {
    return _fragmentShader;
}

bool ShaderProgram::isValid() {
    return _isValid;
}

ShaderProgram::ShaderProgram(id <MTLLibrary> library,
                             const std::string &vertexSource,
                             const std::string &fragmentSource,
                             const ShaderMacroCollection &macroInfo) {
    ID = ShaderProgram::_counter;
    ShaderProgram::_counter += 1;
    
    _library = library;
    _createProgram(vertexSource, fragmentSource, macroInfo);
    _isValid = true;
}

MTLFunctionConstantValues *ShaderProgram::makeFunctionConstants(const ShaderMacroCollection &macroInfo) {
    auto functionConstants = ShaderMacroCollection::createDefaultFunction();
    std::for_each(macroInfo._value.begin(), macroInfo._value.end(), [&](const std::pair<MacroName, std::pair<int, MTLDataType>> &info) {
        if (info.second.second == MTLDataTypeBool) {
            bool property;
            if (info.second.first == 1) {
                property = true;
            } else {
                property = false;
            }
            [functionConstants setConstantValue:&property type:MTLDataTypeBool atIndex:info.first];
        } else {
            auto &property = info.second.first;
            [functionConstants setConstantValue:&property type:info.second.second atIndex:info.first];
        }
    });
    return functionConstants;
}

void ShaderProgram::_createProgram(const std::string &vertexSource, const std::string &fragmentSource,
                                   const ShaderMacroCollection &macroInfo) {
    auto functionConstants = makeFunctionConstants(macroInfo);
    _vertexShader = [_library newFunctionWithName:[NSString stringWithCString:vertexSource.c_str() encoding:NSUTF8StringEncoding]
                                   constantValues:functionConstants error:nullptr];
    _fragmentShader = [_library newFunctionWithName:[NSString stringWithCString:fragmentSource.c_str() encoding:NSUTF8StringEncoding]
                                     constantValues:functionConstants error:nullptr];
}


}
