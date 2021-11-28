//
//  render_pipeline_state.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "render_pipeline_state.h"
#include "metal_renderer.h"
#include "../shader/shader.h"

namespace vox {
RenderPipelineState::RenderPipelineState(MetalRenderer* _render, MTLRenderPipelineDescriptor* descriptor):
_render(_render) {
    _handle = [_render->device newRenderPipelineStateWithDescriptor:descriptor
                                                            options:MTLPipelineOptionArgumentInfo
                                                         reflection:_reflection error:NULL];
    _recordVertexLocation();
}

void RenderPipelineState::groupingOtherUniformBlock() {
    if (otherUniformBlock.constUniforms.size() > 0) {
        _groupingSubOtherUniforms(otherUniformBlock.constUniforms, false);
    }
    
    if (otherUniformBlock.textureUniforms.size() > 0) {
        _groupingSubOtherUniforms(otherUniformBlock.textureUniforms, true);
    }
}

void RenderPipelineState::uploadAll(const ShaderUniformBlock& uniformBlock, const ShaderData& shaderData) {
    uploadUniforms(uniformBlock, shaderData);
    uploadTextures(uniformBlock, shaderData);
}

void RenderPipelineState::uploadUniforms(const ShaderUniformBlock& uniformBlock, const ShaderData& shaderData) {
    
}

void RenderPipelineState::uploadTextures(const ShaderUniformBlock& uniformBlock, const ShaderData& shaderData) {
    
}

void RenderPipelineState::_recordVertexLocation() {
    auto count = [[*_reflection vertexArguments] count];
    if (count != 0) {
        for (size_t i = 0; i < count; i++) {
            const auto& aug = [*_reflection vertexArguments][i];
            const auto type = aug.bufferDataType;
            if (type == MTLDataTypeStruct) {
                continue;
            }
            
            const auto name = [aug.name cStringUsingEncoding:NSUTF8StringEncoding];
            const auto location = aug.index;
            const auto group = Shader::_getShaderPropertyGroup(name);
            
            ShaderUniform shaderUniform;
            shaderUniform.name = name;
            shaderUniform.propertyId = Shader::getPropertyByName(name)._uniqueId;
            shaderUniform.location = location;
            
            switch (type) {
                case MTLDataTypeFloat:
                case MTLDataTypeFloat2:
                case MTLDataTypeFloat3:
                case MTLDataTypeFloat4:
                case MTLDataTypeInt:
                case MTLDataTypeFloat4x4 :
                    
                    break;
                    
                default:
                    break;
            }
            _groupingUniform(shaderUniform, group, false);
        }
    }
    
    count = [[*_reflection fragmentArguments] count];
    if (count != 0) {
        for (size_t i = 0; i < count; i++) {
            const auto& aug = [*_reflection fragmentArguments][i];
            const auto type = aug.type;
            
            const auto name = [aug.name cStringUsingEncoding:NSUTF8StringEncoding];
            const auto location = aug.index;
            const auto group = Shader::_getShaderPropertyGroup(name);
            
            ShaderUniform shaderUniform;
            shaderUniform.name = name;
            shaderUniform.propertyId = Shader::getPropertyByName(name)._uniqueId;
            shaderUniform.location = location;
            
            if (type == MTLArgumentTypeBuffer) {
                switch (aug.bufferDataType) {
                    case MTLDataTypeFloat:
                    case MTLDataTypeFloat2:
                    case MTLDataTypeFloat3:
                    case MTLDataTypeFloat4:
                    case MTLDataTypeInt:
                    case MTLDataTypeFloat4x4 :
                    case MTLDataTypeStruct :
                        break;
                    default:
                        break;
                }
            } else if (type == MTLArgumentTypeSampler) {
                
            } else if (type == MTLArgumentTypeTexture) {
            }
            
            _groupingUniform(shaderUniform, group, false);
        }
    }
}

void RenderPipelineState::_groupingUniform(const ShaderUniform& uniform,
                                           const std::optional<ShaderDataGroup>& group, bool isTexture) {
    if (group != std::nullopt) {
        switch (group.value()) {
            case ShaderDataGroup::Scene:
                if (isTexture) {
                    sceneUniformBlock.textureUniforms.push_back(uniform);
                } else {
                    sceneUniformBlock.constUniforms.push_back(uniform);
                }
                break;
            case ShaderDataGroup::Camera:
                if (isTexture) {
                    cameraUniformBlock.textureUniforms.push_back(uniform);
                } else {
                    cameraUniformBlock.constUniforms.push_back(uniform);
                }
                break;
            case ShaderDataGroup::Renderer:
                if (isTexture) {
                    rendererUniformBlock.textureUniforms.push_back(uniform);
                } else {
                    rendererUniformBlock.constUniforms.push_back(uniform);
                }
                break;
            case ShaderDataGroup::Material:
                if (isTexture) {
                    materialUniformBlock.textureUniforms.push_back(uniform);
                } else {
                    materialUniformBlock.constUniforms.push_back(uniform);
                }
                break;
        }
    } else {
        if (isTexture) {
            otherUniformBlock.textureUniforms.push_back(uniform);
        } else {
            otherUniformBlock.constUniforms.push_back(uniform);
        }
    }
}

void RenderPipelineState::_groupingSubOtherUniforms(std::vector<ShaderUniform>& uniforms, bool isTexture) {
    for (size_t i = 0; i < uniforms.size(); i++) {
        const auto& uniform = uniforms[i];
        const auto group = Shader::_getShaderPropertyGroup(uniform.name);
        if (group != std::nullopt) {
            auto iter = std::find_if(uniforms.begin(), uniforms.end(),
                                     [&](const auto& u){
                return u.name == uniform.name;
            });
            
            if (iter != uniforms.end()) {
                uniforms.erase(iter);
            }
            _groupingUniform(uniform, group, isTexture);
        }
    }
}

}
