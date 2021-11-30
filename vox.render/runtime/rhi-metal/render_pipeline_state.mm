//
//  render_pipeline_state.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "render_pipeline_state.h"
#include "metal_renderer.h"
#include "../shader/shader.h"
#include "maths/matrix.h"
#include "log.h"
#include <iomanip>
#include <type_traits>
#include <typeindex>
#include <typeinfo>
#include <unordered_map>

namespace vox {
RenderPipelineState::RenderPipelineState(MetalRenderer* _render, MTLRenderPipelineDescriptor* descriptor):
_render(_render) {
    MTLRenderPipelineReflection *_reflection;
    NSError *error = nil;
    _handle = [_render->device newRenderPipelineStateWithDescriptor:descriptor
                                                            options:MTLPipelineOptionArgumentInfo
                                                         reflection:&_reflection error:&error];
    if (error != nil)
    {
        NSLog(@"Error: failed to create Metal pipeline state: %@", error);
    }
    
    _recordVertexLocation(_reflection);
}

void RenderPipelineState::groupingOtherUniformBlock() {
    if (otherUniformBlock.constUniforms.size() > 0) {
        _groupingSubOtherUniforms(otherUniformBlock.constUniforms, false);
    }
    
    if (otherUniformBlock.textureUniforms.size() > 0) {
        _groupingSubOtherUniforms(otherUniformBlock.textureUniforms, true);
    }
}

namespace {
template<class T, class F>
inline std::pair<const std::type_index, std::function<void(std::any const&, size_t, id <MTLRenderCommandEncoder>)>>
to_any_visitor(F const &f) {
    return {
        std::type_index(typeid(T)),
        [g = f](std::any const &a, size_t location, id <MTLRenderCommandEncoder> encoder)
        {
            if constexpr (std::is_void_v<T>)
                g();
            else
                g(std::any_cast<T const&>(a), location, encoder);
        }
    };
}

static std::unordered_map<
std::type_index, std::function<void(std::any const&, size_t, id <MTLRenderCommandEncoder>)>>
vertex_any_visitor {
    to_any_visitor<int>([](const int& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(int) atIndex:location];
    }),
    to_any_visitor<float>([](const float& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(float) atIndex:location];
    }),
    to_any_visitor<Float2>([](const Float2& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(Float2) atIndex:location];
    }),
    to_any_visitor<Float3>([](const Float3& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(Float3) atIndex:location];
    }),
    to_any_visitor<Float4>([](const Float4& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(Float4) atIndex:location];
    }),
    to_any_visitor<Color>([](const Color& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(Color) atIndex:location];
    }),
    to_any_visitor<Matrix>([](const Matrix& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(Matrix) atIndex:location];
    }),
    to_any_visitor<id<MTLBuffer>>([](const id<MTLBuffer>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBuffer:x offset:0 atIndex:location];
    }),
    to_any_visitor<id<MTLTexture>>([](const id<MTLTexture>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexTexture:x atIndex:location];
    }),
};

static std::unordered_map<
std::type_index, std::function<void(std::any const&, size_t, id <MTLRenderCommandEncoder>)>>
fragment_any_visitor {
    to_any_visitor<int>([](const int& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(int) atIndex:location];
    }),
    to_any_visitor<float>([](const float& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(float) atIndex:location];
    }),
    to_any_visitor<Float2>([](const Float2& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(Float2) atIndex:location];
    }),
    to_any_visitor<Float3>([](const Float3& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(Float3) atIndex:location];
    }),
    to_any_visitor<Float4>([](const Float4& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(Float4) atIndex:location];
    }),
    to_any_visitor<Color>([](const Color& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(Color) atIndex:location];
    }),
    to_any_visitor<Matrix>([](const Matrix& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(Matrix) atIndex:location];
    }),
    to_any_visitor<id<MTLBuffer>>([](const id<MTLBuffer>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBuffer:x offset:0 atIndex:location];
    }),
    to_any_visitor<id<MTLTexture>>([](const id<MTLTexture>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentTexture:x atIndex:location];
    }),
};

inline void process(const ShaderUniform& uniform, const std::any& a, id <MTLRenderCommandEncoder> encoder)
{
    const auto& any_visitor = uniform.type == MTLFunctionTypeVertex? vertex_any_visitor: fragment_any_visitor;
    if (const auto it = any_visitor.find(std::type_index(a.type()));
        it != any_visitor.cend()) {
        it->second(a, uniform.location, encoder);
    } else {
        log::Log() << "Unregistered type "<< std::quoted(a.type().name());
    }
}

}

void RenderPipelineState::uploadAll(const ShaderUniformBlock& uniformBlock, const ShaderData& shaderData) {
    uploadUniforms(uniformBlock, shaderData);
    uploadTextures(uniformBlock, shaderData);
}

void RenderPipelineState::uploadUniforms(const ShaderUniformBlock& uniformBlock, const ShaderData& shaderData) {
    const auto& properties = shaderData._properties;
    const auto& constUniforms = uniformBlock.constUniforms;
    
    for (size_t i = 0; i < constUniforms.size(); i++) {
        const auto& uniform = constUniforms[i];
        auto iter = properties.find(uniform.propertyId);
        if (iter != properties.end()) {
            process(uniform, *iter, _render->renderEncoder);
        }
    }
}

void RenderPipelineState::uploadTextures(const ShaderUniformBlock& uniformBlock, const ShaderData& shaderData) {
    const auto& properties = shaderData._properties;
    const auto& textureUniforms = uniformBlock.textureUniforms;
    
    if (!textureUniforms.empty()) {
        for (size_t i = 0; i < textureUniforms.size(); i++) {
            const auto& uniform = textureUniforms[i];
            auto iter = properties.find(uniform.propertyId);
            if (iter != properties.end()) {
                process(uniform, *iter, _render->renderEncoder);
            }
        }
    }
}

void RenderPipelineState::_recordVertexLocation(MTLRenderPipelineReflection* reflection) {
    auto count = [[reflection vertexArguments] count];
    if (count != 0) {
        for (size_t i = 0; i < count; i++) {
            const auto& aug = [reflection vertexArguments][i];
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
            shaderUniform.type = MTLFunctionTypeVertex;
            
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
    
    count = [[reflection fragmentArguments] count];
    if (count != 0) {
        for (size_t i = 0; i < count; i++) {
            const auto& aug = [reflection fragmentArguments][i];
            const auto type = aug.type;
            
            const auto name = [aug.name cStringUsingEncoding:NSUTF8StringEncoding];
            const auto location = aug.index;
            const auto group = Shader::_getShaderPropertyGroup(name);
            
            ShaderUniform shaderUniform;
            shaderUniform.name = name;
            shaderUniform.propertyId = Shader::getPropertyByName(name)._uniqueId;
            shaderUniform.location = location;
            shaderUniform.type = MTLFunctionTypeFragment;
            
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
