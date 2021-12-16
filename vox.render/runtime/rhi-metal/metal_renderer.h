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
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <ModelIO/ModelIO.h>
#import <QuartzCore/QuartzCore.h>

namespace vox {
/// Metal renderer.
class MetalRenderer {
public:
    const int maxAnisotropy = 8;
    
    Canvas* canvas;
    ResourceCache resouceCache;
    id <MTLDevice> device;
    id <MTLCommandQueue> commandQueue;
    id <MTLLibrary> library;
    
    id <MTLCommandBuffer> commandBuffer;
    id <MTLRenderCommandEncoder> renderEncoder;
    MTLRenderPassDescriptor *renderPassDescriptor;
    
    // todo delete
    MTLPixelFormat colorPixelFormat;
    id <MTLSamplerState> samplerState;
    
    explicit MetalRenderer(Canvas* canvas);
    
    id <MTLSamplerState> buildSamplerState();
    
public:
    void begin();
    
    void end();
    
    void activeRenderTarget(MTLRenderPassDescriptor *renderTarget);
    
    void clearRenderTarget(int clearFlags = CameraClearFlags::Depth | CameraClearFlags::DepthColor,
                           math::Color clearColor = math::Color(0.45f, 0.55f, 0.60f, 1.00f));
    
    void beginRenderPass(MTLRenderPassDescriptor *renderTarget, Camera *camera, int mipLevel = 0);
    
    void endRenderPass();
    
public:
    void setRenderPipelineState(RenderPipelineState *state);
    
    void setDepthStencilState(id <MTLDepthStencilState> depthStencilState);
    
    void setDepthBias(float depthBias, float slopeScale, float clamp);
    
    void setStencilReferenceValue(uint32_t referenceValue);
    
    void setBlendColor(float red, float green, float blue, float alpha);
    
    void setCullMode(MTLCullMode cullMode);
    
    void bindTexture(id <MTLTexture> texture, int location);
    
    void drawPrimitive(SubMesh *subPrimitive);

public:
    id<MTLTexture> buildTexture(int width, int height, MTLPixelFormat pixelFormat,
                                MTLTextureUsage usage = MTLTextureUsageShaderRead|MTLTextureUsageRenderTarget);
    
    id<MTLTexture> loadTexture(const std::string& path, const std::string& imageName, bool isTopLeft = true);
    
    id<MTLTexture> loadTexture(MDLTexture* texture);
    
    id<MTLTexture> loadCubeTexture(const std::string& imageName);
    
    id<MTLTexture> loadTextureArray(const std::string& path, const std::vector<std::string>& textureNames);
    
private:
    CAMetalLayer *layer;
    id <CAMetalDrawable> drawable;
    
    MTKTextureLoader* textureLoader;
    id<MTLTexture> depthTexture;
};

}
#endif /* metal_renderer_hpp */
