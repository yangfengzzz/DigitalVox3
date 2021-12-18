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

namespace vox {
RenderPipelineState::RenderPipelineState(MetalRenderer* _render, MTLRenderPipelineDescriptor* descriptor):
_render(_render) {
    MTLRenderPipelineReflection *_reflection;
    NSError *error = nil;
    _handle = [_render->_device newRenderPipelineStateWithDescriptor:descriptor
                                                             options:MTLPipelineOptionArgumentInfo
                                                          reflection:&_reflection error:&error];
    if (error != nil)
    {
        NSLog(@"Error: failed to create Metal pipeline state: %@", error);
    }
    
    _recordVertexLocation(_reflection);
}

void RenderPipelineState::groupingOtherUniformBlock() {
    if (otherUniformBlock.size() > 0) {
        _groupingSubOtherUniforms(otherUniformBlock);
    }
}

std::unordered_map<
std::type_index, std::function<void(std::any const&, size_t, id <MTLRenderCommandEncoder>)>>
RenderPipelineState::vertex_any_uploader {
    to_any_uploader<int>([](const int& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(int) atIndex:location];
    }),
    to_any_uploader<float>([](const float& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(float) atIndex:location];
    }),
    to_any_uploader<Float2>([](const Float2& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(Float2) atIndex:location];
    }),
    to_any_uploader<Float3>([](const Float3& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:16 atIndex:location]; // float3 simd is extented from float4
    }),
    to_any_uploader<Float4>([](const Float4& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(Float4) atIndex:location];
    }),
    to_any_uploader<Color>([](const Color& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(Color) atIndex:location];
    }),
    to_any_uploader<Matrix>([](const Matrix& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBytes: &x length:sizeof(Matrix) atIndex:location];
    }),
    to_any_uploader<id<MTLBuffer>>([](const id<MTLBuffer>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexBuffer:x offset:0 atIndex:location];
    }),
    to_any_uploader<id<MTLTexture>>([](const id<MTLTexture>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setVertexTexture:x atIndex:location];
    }),
};

std::unordered_map<
std::type_index, std::function<void(std::any const&, size_t, id <MTLRenderCommandEncoder>)>>
RenderPipelineState::fragment_any_uploader {
    to_any_uploader<int>([](const int& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(int) atIndex:location];
    }),
    to_any_uploader<float>([](const float& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(float) atIndex:location];
    }),
    to_any_uploader<Float2>([](const Float2& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(Float2) atIndex:location];
    }),
    to_any_uploader<Float3>([](const Float3& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:16 atIndex:location]; // float3 simd is extented from float4
    }),
    to_any_uploader<Float4>([](const Float4& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(Float4) atIndex:location];
    }),
    to_any_uploader<Color>([](const Color& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(Color) atIndex:location];
    }),
    to_any_uploader<Matrix>([](const Matrix& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: &x length:sizeof(Matrix) atIndex:location];
    }),
    to_any_uploader<id<MTLBuffer>>([](const id<MTLBuffer>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBuffer:x offset:0 atIndex:location];
    }),
    to_any_uploader<id<MTLTexture>>([](const id<MTLTexture>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentTexture:x atIndex:location];
    }),
};

void RenderPipelineState::process(const ShaderUniform& uniform, const std::any& a, id <MTLRenderCommandEncoder> encoder) {
    const auto& any_uploader = uniform.type == MTLFunctionTypeVertex?
    RenderPipelineState::vertex_any_uploader: RenderPipelineState::fragment_any_uploader;
    
    if (const auto it = any_uploader.find(std::type_index(a.type()));
        it != any_uploader.cend()) {
        it->second(a, uniform.location, encoder);
    } else {
        log::Log() << "Unregistered type "<< std::quoted(a.type().name());
    }
}

void RenderPipelineState::uploadAll(const std::vector<ShaderUniform>& uniformBlock, const ShaderData& shaderData) {
    uploadUniforms(uniformBlock, shaderData);
}

void RenderPipelineState::uploadUniforms(const std::vector<ShaderUniform>& uniformBlock, const ShaderData& shaderData) {
    const auto& properties = shaderData._properties;
    const auto& constUniforms = uniformBlock;
    
    for (size_t i = 0; i < constUniforms.size(); i++) {
        const auto& uniform = constUniforms[i];
        auto iter = properties.find(uniform.propertyId);
        if (iter != properties.end()) {
            process(uniform, iter->second, _render->_renderEncoder);
        }
    }
}

void RenderPipelineState::_recordVertexLocation(MTLRenderPipelineReflection* reflection) {
    auto count = [[reflection vertexArguments] count];
    if (count != 0) {
        for (size_t i = 0; i < count; i++) {
            const auto& aug = [reflection vertexArguments][i];
            const auto name = [aug.name cStringUsingEncoding:NSUTF8StringEncoding];
            const auto location = aug.index;
            const auto group = Shader::_getShaderPropertyGroup(name);
            
            ShaderUniform shaderUniform;
            shaderUniform.name = name;
            shaderUniform.propertyId = Shader::getPropertyByName(name)->_uniqueId;
            shaderUniform.location = location;
            shaderUniform.type = MTLFunctionTypeVertex;
            _groupingUniform(shaderUniform, group);
        }
    }
    
    count = [[reflection fragmentArguments] count];
    if (count != 0) {
        for (size_t i = 0; i < count; i++) {
            const auto& aug = [reflection fragmentArguments][i];
            const auto name = [aug.name cStringUsingEncoding:NSUTF8StringEncoding];
            const auto location = aug.index;
            const auto group = Shader::_getShaderPropertyGroup(name);
            
            ShaderUniform shaderUniform;
            shaderUniform.name = name;
            shaderUniform.propertyId = Shader::getPropertyByName(name)->_uniqueId;
            shaderUniform.location = location;
            shaderUniform.type = MTLFunctionTypeFragment;
            _groupingUniform(shaderUniform, group);
        }
    }
}

void RenderPipelineState::_groupingUniform(const ShaderUniform& uniform,
                                           const std::optional<ShaderDataGroup::Enum>& group) {
    if (group != std::nullopt) {
        switch (group.value()) {
            case ShaderDataGroup::Scene:
                sceneUniformBlock.push_back(uniform);
                break;
            case ShaderDataGroup::Camera:
                cameraUniformBlock.push_back(uniform);
                break;
            case ShaderDataGroup::Renderer:
                rendererUniformBlock.push_back(uniform);
                break;
            case ShaderDataGroup::Material:
                materialUniformBlock.push_back(uniform);
                break;
        }
    } else {
        otherUniformBlock.push_back(uniform);
    }
}

void RenderPipelineState::_groupingSubOtherUniforms(std::vector<ShaderUniform>& uniforms) {
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
            _groupingUniform(uniform, group);
        }
    }
}

}
