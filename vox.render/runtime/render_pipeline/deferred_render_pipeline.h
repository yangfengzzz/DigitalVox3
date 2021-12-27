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
    
    void _drawElement(const std::vector<RenderElement>& renderQueue, RenderPass* pass);
    
    void _drawDirectionalLights();
    
private:
    MTLPixelFormat _diffuse_occlusion_GBufferFormat;
    id <MTLTexture> _diffuse_occlusion_GBuffer;
    MTLPixelFormat _specular_roughness_GBufferFormat;
    id <MTLTexture> _specular_roughness_GBuffer;
    MTLPixelFormat _normal_GBufferFormat;
    id <MTLTexture> _normal_GBuffer;
    MTLPixelFormat _emissive_GBufferFormat;
    id <MTLTexture> _emissive_GBuffer;

    // GBuffer
    MTLRenderPassDescriptor *_GBufferRenderPassDescriptor;
    MTLRenderPipelineDescriptor* _GBufferRenderPipelineDescriptor;
    MTLStencilDescriptor *_GBufferStencilStateDesc;
    
    // Compositor
    MTLRenderPassDescriptor *_finalRenderPassDescriptor;
    MTLRenderPipelineDescriptor *_directionalLightPipelineDesc;
    id <MTLDepthStencilState> _directionLightDepthStencilState;

};

}

#endif /* deferred_render_pipeline_hpp */
