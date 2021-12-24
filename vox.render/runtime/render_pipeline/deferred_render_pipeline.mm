//
//  defered_render_pipeline.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/24.
//

#include "deferred_render_pipeline.h"
#include "../camera.h"
#include "../engine.h"
#include "../renderer.h"

namespace vox {
DeferredRenderPipeline::DeferredRenderPipeline(Camera* camera):
RenderPipeline(camera) {
    const auto& loader = camera->engine()->resourceLoader();
    
    _albedo_specular_GBufferFormat = MTLPixelFormatRGBA8Unorm_sRGB;
    _normal_shadow_GBufferFormat = MTLPixelFormatRGBA8Snorm;
    _depth_GBufferFormat = MTLPixelFormatR32Float;
    
    _renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];
    _renderPipelineDescriptor.label = @"G-buffer Creation";
    _renderPipelineDescriptor.colorAttachments[0].pixelFormat = _albedo_specular_GBufferFormat;
    _renderPipelineDescriptor.colorAttachments[1].pixelFormat = _normal_shadow_GBufferFormat;
    _renderPipelineDescriptor.colorAttachments[2].pixelFormat = _depth_GBufferFormat;
    
    // Create a render pass descriptor to create an encoder for rendering to the GBuffers.
    // The encoder stores rendered data of each attachment when encoding ends.
    _GBufferRenderPassDescriptor = [MTLRenderPassDescriptor new];
    
    _GBufferRenderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionDontCare;
    _GBufferRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    _GBufferRenderPassDescriptor.colorAttachments[1].loadAction = MTLLoadActionDontCare;
    _GBufferRenderPassDescriptor.colorAttachments[1].storeAction = MTLStoreActionStore;
    _GBufferRenderPassDescriptor.colorAttachments[2].loadAction = MTLLoadActionDontCare;
    _GBufferRenderPassDescriptor.colorAttachments[2].storeAction = MTLStoreActionStore;
    _GBufferRenderPassDescriptor.depthAttachment.clearDepth = 1.0;
    _GBufferRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    _GBufferRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;

    _GBufferRenderPassDescriptor.stencilAttachment.clearStencil = 0;
    _GBufferRenderPassDescriptor.stencilAttachment.loadAction = MTLLoadActionClear;
    _GBufferRenderPassDescriptor.stencilAttachment.storeAction = MTLStoreActionStore;

    // Create a render pass descriptor for thelighting and composition pass
    _finalRenderPassDescriptor = [MTLRenderPassDescriptor new];

    // Whatever rendered in the final pass needs to be stored so it can be displayed
    _finalRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    _finalRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionLoad;
    _finalRenderPassDescriptor.stencilAttachment.loadAction = MTLLoadActionLoad;
    
    auto createFrameBuffer = [&](GLFWwindow* window, int width, int height){
        int buffer_width, buffer_height;
        glfwGetFramebufferSize(window, &buffer_width, &buffer_height);
        MTLTextureDescriptor *GBufferTextureDesc =
            [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm_sRGB
                                                               width:buffer_width
                                                              height:buffer_height
                                                           mipmapped:NO];
        GBufferTextureDesc.textureType = MTLTextureType2D;
        GBufferTextureDesc.usage |= MTLTextureUsageRenderTarget;
        GBufferTextureDesc.storageMode = MTLStorageModePrivate;

        GBufferTextureDesc.pixelFormat = _albedo_specular_GBufferFormat;
        _albedo_specular_GBuffer = loader->buildTexture(GBufferTextureDesc);
        _albedo_specular_GBuffer.label = @"Albedo + Shadow GBuffer";
        GBufferTextureDesc.pixelFormat = _normal_shadow_GBufferFormat;
        _normal_shadow_GBuffer = loader->buildTexture(GBufferTextureDesc);
        _normal_shadow_GBuffer.label   = @"Normal + Specular GBuffer";
        GBufferTextureDesc.pixelFormat = _depth_GBufferFormat;
        _normal_shadow_GBuffer = loader->buildTexture(GBufferTextureDesc);
        _depth_GBuffer.label = @"Depth GBuffer";
        
        _GBufferRenderPassDescriptor.colorAttachments[0].texture = _albedo_specular_GBuffer;
        _GBufferRenderPassDescriptor.colorAttachments[1].texture = _normal_shadow_GBuffer;
        _GBufferRenderPassDescriptor.colorAttachments[2].texture = _depth_GBuffer;
    };
    createFrameBuffer(_camera->engine()->canvas()->handle(), 0, 0);
    Canvas::resize_callbacks.push_back(createFrameBuffer);
}

DeferredRenderPipeline::~DeferredRenderPipeline() {
    
}

void DeferredRenderPipeline::_drawRenderPass(RenderPass* pass, Camera* camera,
                                             std::optional<TextureCubeFace> cubeFace,
                                             int mipLevel) {
    pass->preRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
    
    if (pass->enabled) {
        const auto& engine = camera->engine();
        const auto& scene = camera->scene();
        const auto& background = scene->background;
        auto& rhi = engine->_hardwareRenderer;
        
        // command encoder
        if (pass->renderOverride) {
            pass->render(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
        } else {
            if (background.mode == BackgroundMode::Sky) {
                _drawSky(background.sky);
            }
        }
        
        rhi.endRenderPass();// renderEncoder
    }
    
    pass->postRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
}

}
