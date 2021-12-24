//
//  defered_render_pipeline.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/24.
//

#ifndef deferred_render_pipeline_hpp
#define deferred_render_pipeline_hpp

#include "render_pipeline.h"

namespace vox {
class DeferredRenderPipeline :public RenderPipeline {
public:
    DeferredRenderPipeline(Camera* camera);
    
    ~DeferredRenderPipeline();
    
private:
    void _drawRenderPass(RenderPass* pass, Camera* camera,
                         std::optional<TextureCubeFace> cubeFace = std::nullopt,
                         int mipLevel = 0) override;
    
private:
    MTLPixelFormat _albedo_specular_GBufferFormat;
    id <MTLTexture> _albedo_specular_GBuffer;
    MTLPixelFormat _normal_shadow_GBufferFormat;
    id <MTLTexture> _normal_shadow_GBuffer;
    MTLPixelFormat _depth_GBufferFormat;
    id <MTLTexture> _depth_GBuffer;
    
    MTLRenderPipelineDescriptor* _renderPipelineDescriptor;
    MTLRenderPassDescriptor *_GBufferRenderPassDescriptor;
    MTLRenderPassDescriptor *_finalRenderPassDescriptor;
};

}

#endif /* deferred_render_pipeline_hpp */
