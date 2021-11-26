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
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

namespace vox {
class Camera;

/// Metal renderer.
class MetalRenderer {
public:
    const int maxAnisotropy = 8;
    
    Canvas canvas;
    id <MTLDevice> device;
    // var resouceCache: ResourceCache!
    id <MTLCommandQueue> commandQueue;
    id<MTLLibrary> library;
    
    id<MTLCommandBuffer> commandBuffer;
    id<MTLRenderCommandEncoder> renderEncoder;
    MTLRenderPassDescriptor* renderPassDescriptor;
    
    // todo delete
    MTLPixelFormat colorPixelFormat;
    id<MTLSamplerState> samplerState;
    
    void reinit(Canvas canvas);
    
    id<MTLSamplerState> buildSamplerState();
    
public:
    void begin();

    void end();
    
    void activeRenderTarget(MTLRenderPassDescriptor* renderTarget);
    
    void clearRenderTarget(int clearFlags = CameraClearFlags::Depth | CameraClearFlags::DepthColor,
                           Color clearColor = Color(0.45f, 0.55f, 0.60f, 1.00f));
    
    void beginRenderPass(MTLRenderPassDescriptor* renderTarget, Camera* camera, int mipLevel= 0);
    
    void endRenderPass();
    
private:
    CAMetalLayer *layer;
    id<CAMetalDrawable> drawable;
};

}
#endif /* metal_renderer_hpp */
