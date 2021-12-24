//
//  metal_renderer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef metal_renderer_hpp
#define metal_renderer_hpp

#include "maths/color.h"
#include "../enums/camera_clear_flags.h"
#include "../canvas.h"
#include "resource_cache_state.h"
#include "metal_loader.h"
#import <QuartzCore/QuartzCore.h>

namespace vox {
/**
 * Metal renderer.
 */
class MetalRenderer {
public:
    ResourceCache resouceCache;
    
    explicit MetalRenderer(Canvas* canvas);
    
    id <MTLLibrary> library();
    
    MTLPixelFormat colorPixelFormat();
    
    MetalLoaderPtr resourceLoader();
    
public:
    void begin();
    
    void end();
    
    void activeRenderTarget(MTLRenderPassDescriptor *renderTarget);
    
    void clearRenderTarget(int clearFlags = CameraClearFlags::Depth | CameraClearFlags::DepthColor,
                           math::Color clearColor = math::Color(0.45f, 0.55f, 0.60f, 1.00f));
    
    void beginRenderPass(MTLRenderPassDescriptor *renderTarget, Camera *camera, int mipLevel = 0);
    
    void endRenderPass();
    
public:
    void synchronizeResource(id<MTLResource> resource);
    
    id<MTLTexture> createTextureArray(const std::vector<id<MTLTexture>>::iterator& texturesBegin,
                                      const std::vector<id<MTLTexture>>::iterator& texturesEnd,
                                      id<MTLTexture> packedTextures);
    
    id<MTLTexture> createCubeTextureArray(const std::vector<id<MTLTexture>>::iterator& texturesBegin,
                                          const std::vector<id<MTLTexture>>::iterator& texturesEnd,
                                          id<MTLTexture> packedTextures);
    
    id<MTLTexture> createAtlas(const std::array<id<MTLTexture>, 4>& textures,
                               id<MTLTexture> packedTextures);
    
    id<MTLTexture> createCubeAtlas(const std::array<id<MTLTexture>, 6>& textures,
                                   id<MTLTexture> packedTextures);
    
public:
    template<typename T>
    void setVertexBytes(T& data, uint32_t location) {
        [_renderEncoder setVertexBytes: &data length:sizeof(T) atIndex:location];
    }
    
    void setVertexBuffer(id<MTLBuffer> buffer, uint32_t offset, uint32_t index);
    
    id <MTLRenderPipelineState> createRenderPipelineState(MTLRenderPipelineDescriptor *descriptor);
    
    void setRenderPipelineState(id <MTLRenderPipelineState> state);
    
    void setRenderPipelineState(RenderPipelineState *state);
    
    void setDepthStencilState(MTLDepthStencilDescriptor* depthStencilDescriptor);
    
    void setDepthStencilState(id <MTLDepthStencilState> depthStencilState);
    
    void setDepthBias(float depthBias, float slopeScale, float clamp);
    
    void setStencilReferenceValue(uint32_t referenceValue);
    
    void setBlendColor(float red, float green, float blue, float alpha);
    
    void setCullMode(MTLCullMode cullMode);
    
    void bindTexture(id <MTLTexture> texture, int location);
    
    void drawPrimitive(const SubMesh *subPrimitive) const;
    
private:
    id <MTLSamplerState> buildSamplerState();
    
private:
    friend class RenderPipelineState;
    friend class ComputePipelineState;
    
    const int maxAnisotropy = 8;
    
    Canvas* _canvas;
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
    id <MTLLibrary> _library;
    CAMetalLayer *_layer;
    id <CAMetalDrawable> _drawable;
    MetalLoaderPtr _metalResourceLoader;
    
    id <MTLCommandBuffer> _commandBuffer;
    id <MTLRenderCommandEncoder> _renderEncoder;
    MTLRenderPassDescriptor *_renderPassDescriptor;
    
    // todo delete
    MTLPixelFormat _colorPixelFormat;
    id <MTLSamplerState> _samplerState;
    
    id<MTLTexture> _depthTexture;
};

}
#endif /* metal_renderer_hpp */
