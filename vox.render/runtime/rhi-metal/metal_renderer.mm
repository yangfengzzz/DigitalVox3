//
//  metal_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "metal_renderer.h"
#include "engine.h"
#include "camera.h"
#include "render_pipeline_state.h"
#include "../graphics/submesh.h"
#include "../../gui/imgui_impl_metal.h"

namespace vox {
MetalRenderer::MetalRenderer(Canvas* canvas):
canvas(canvas),
resouceCache(this) {
    device = MTLCreateSystemDefaultDevice();
    commandQueue = [device newCommandQueue];
    metalResourceLoader = std::make_shared<MetalLoader>(device);
    
    // self.resouceCache = ResourceCache(self);
    library = [device newDefaultLibrary];
    
    colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    samplerState = buildSamplerState();
    
    ImGui_ImplMetal_Init(device);
    
    NSWindow *nswin = glfwGetCocoaWindow(canvas->handle());
    layer = [CAMetalLayer layer];
    layer.device = device;
    layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    nswin.contentView.layer = layer;
    nswin.contentView.wantsLayer = YES;
    
    auto createFrameBuffer = [&](GLFWwindow* window, int width, int height){
        int buffer_width, buffer_height;
        glfwGetFramebufferSize(window, &buffer_width, &buffer_height);
        layer.drawableSize = CGSizeMake(buffer_width, buffer_height);
        
        // depth texture
        depthTexture = metalResourceLoader->buildTexture(buffer_width, buffer_height, MTLPixelFormatDepth32Float);
    };
    createFrameBuffer(canvas->handle(), 0, 0);
    Canvas::resize_callbacks.push_back(createFrameBuffer);
}

id <MTLSamplerState> MetalRenderer::buildSamplerState() {
    auto *descriptor = [[MTLSamplerDescriptor alloc] init];
    descriptor.sAddressMode = MTLSamplerAddressModeRepeat;
    descriptor.tAddressMode = MTLSamplerAddressModeRepeat;
    descriptor.mipFilter = MTLSamplerMipFilterLinear;
    descriptor.maxAnisotropy = maxAnisotropy;
    return [device newSamplerStateWithDescriptor:descriptor];
}

void MetalRenderer::begin() {
    commandBuffer = [commandQueue commandBuffer];
    drawable = [layer nextDrawable];
}

void MetalRenderer::end() {
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}

void MetalRenderer::activeRenderTarget(MTLRenderPassDescriptor *renderTarget) {
    if (renderTarget != nullptr) {
        renderPassDescriptor = renderTarget;
    } else {
        renderPassDescriptor = [MTLRenderPassDescriptor new];
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
        renderPassDescriptor.depthAttachment.texture = depthTexture;
    }
}

void MetalRenderer::clearRenderTarget(int clearFlags,
                                      Color clearColor) {
    //TODO fix
    renderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    renderPassDescriptor.stencilAttachment.loadAction = MTLLoadActionClear;
    if (clearFlags == CameraClearFlags::DepthColor) {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    }
    renderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
    renderPassDescriptor.stencilAttachment.storeAction = MTLStoreActionStore;
}

void MetalRenderer::beginRenderPass(MTLRenderPassDescriptor *renderTarget, Camera *camera, int mipLevel) {
    renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    if (renderTarget != nullptr) {
        
        [renderEncoder setViewport:MTLViewport{
            0, 0,
            static_cast<double>(renderTarget.colorAttachments[0].texture.width >> mipLevel),
            static_cast<double>(renderTarget.colorAttachments[0].texture.height >> mipLevel),
            0, 1}];
    } else {
        const auto &viewport = camera->viewport();
        int width, height;
        glfwGetFramebufferSize(canvas->handle(), &width, &height);
        
        [renderEncoder setViewport:MTLViewport{
            viewport.x * width,
            viewport.y * height,
            viewport.z * width,
            viewport.w * height,
            0, 1}];
    }
    
    [renderEncoder setFragmentSamplerState:samplerState atIndex:0];
}

void MetalRenderer::endRenderPass() {
    ImDrawData *draw_data = ImGui::GetDrawData();
    if (draw_data != nullptr) {
        [renderEncoder pushDebugGroup:@"Dear ImGui rendering"];
        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
        [renderEncoder popDebugGroup];
    }
    
    [renderEncoder endEncoding];
}

void MetalRenderer::setRenderPipelineState(RenderPipelineState *state) {
    [renderEncoder setRenderPipelineState:state->handle()];
}

void MetalRenderer::setDepthStencilState(MTLDepthStencilDescriptor* depthStencilDescriptor) {
    auto depthStencilState = [device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    [renderEncoder setDepthStencilState:depthStencilState];
}

void MetalRenderer::setDepthStencilState(id <MTLDepthStencilState> depthStencilState) {
    [renderEncoder setDepthStencilState:depthStencilState];
}

void MetalRenderer::setDepthBias(float depthBias, float slopeScale, float clamp) {
    [renderEncoder setDepthBias:depthBias slopeScale:slopeScale clamp:clamp];
}

void MetalRenderer::setStencilReferenceValue(uint32_t referenceValue) {
    [renderEncoder setStencilReferenceValue:referenceValue];
}

void MetalRenderer::setBlendColor(float red, float green, float blue, float alpha) {
    [renderEncoder setBlendColorRed:red green:green blue:blue alpha:alpha];
}

void MetalRenderer::setCullMode(MTLCullMode cullMode) {
    [renderEncoder setCullMode:cullMode];
}

void MetalRenderer::bindTexture(id <MTLTexture> texture, int location) {
    [renderEncoder setFragmentTexture:texture atIndex:location];
}

void MetalRenderer::drawPrimitive(SubMesh *subPrimitive) {
    [renderEncoder drawIndexedPrimitives:subPrimitive->topology
                              indexCount:subPrimitive->indexCount
                               indexType:subPrimitive->indexType
                             indexBuffer:subPrimitive->indexBuffer.buffer()
                       indexBufferOffset:subPrimitive->indexBuffer.offset()];
}

//MARK: - Prox Type creation
MetalLoaderPtr MetalRenderer::createResourceLoader() {
    return metalResourceLoader;
}

}
