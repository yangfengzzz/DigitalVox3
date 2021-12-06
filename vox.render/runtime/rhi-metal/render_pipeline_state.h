//
//  render_pipeline_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_pipeline_state_hpp
#define render_pipeline_state_hpp

#import <Metal/Metal.h>
#include "../shader/shader_uniform.h"
#include "../shader/shader_data.h"

namespace vox {
class MetalRenderer;

class RenderPipelineState {
public:
    ShaderUniformBlock sceneUniformBlock = ShaderUniformBlock();
    ShaderUniformBlock cameraUniformBlock = ShaderUniformBlock();
    ShaderUniformBlock rendererUniformBlock = ShaderUniformBlock();
    ShaderUniformBlock materialUniformBlock = ShaderUniformBlock();
    ShaderUniformBlock otherUniformBlock = ShaderUniformBlock();
    
    RenderPipelineState(MetalRenderer* _render, MTLRenderPipelineDescriptor* descriptor);
    
    id <MTLRenderPipelineState> handle() {
        return _handle;
    }
    
public:
    /// Grouping other data.
    void groupingOtherUniformBlock();
    
    /// Upload all shader data in shader uniform block.
    /// - Parameters:
    ///   - uniformBlock: shader Uniform block
    ///   - shaderData: shader data
    void uploadAll(const ShaderUniformBlock& uniformBlock, const ShaderData& shaderData);
    
    /// Upload constant shader data in shader uniform block.
    /// - Parameters:
    ///   - uniformBlock: shader Uniform block
    ///   - shaderData: shader data
    void uploadUniforms(const ShaderUniformBlock& uniformBlock, const ShaderData& shaderData);
    
    /// Upload texture shader data in shader uniform block.
    /// - Parameters:
    ///   - uniformBlock: shader Uniform block
    ///   - shaderData: shader data
    void uploadTextures(const ShaderUniformBlock& uniformBlock, const ShaderData& shaderData);
    
private:
    /// record the location of uniform/attribute.
    void _recordVertexLocation(MTLRenderPipelineReflection* reflection);
    
    void _groupingUniform(const ShaderUniform& uniform,
                          const std::optional<ShaderDataGroup::Enum>& group, bool isTexture);

    void _groupingSubOtherUniforms(std::vector<ShaderUniform>& uniforms, bool isTexture);

    MetalRenderer *_render;
    id <MTLRenderPipelineState> _handle;
};

}

#endif /* render_pipeline_state_hpp */
