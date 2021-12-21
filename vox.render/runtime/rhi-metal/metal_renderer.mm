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
_canvas(canvas),
resouceCache(this) {
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    _library = [_device newDefaultLibrary];
    _metalResourceLoader = std::make_shared<MetalLoader>(_device);

    _colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    _samplerState = buildSamplerState();
    
    ImGui_ImplMetal_Init(_device);
    
    NSWindow *nswin = glfwGetCocoaWindow(canvas->handle());
    _layer = [CAMetalLayer layer];
    _layer.device = _device;
    _layer.pixelFormat = _colorPixelFormat;
    nswin.contentView.layer = _layer;
    nswin.contentView.wantsLayer = YES;
    
    auto createFrameBuffer = [&](GLFWwindow* window, int width, int height){
        int buffer_width, buffer_height;
        glfwGetFramebufferSize(window, &buffer_width, &buffer_height);
        _layer.drawableSize = CGSizeMake(buffer_width, buffer_height);
        
        // depth texture
        _depthTexture = _metalResourceLoader->buildTexture(buffer_width, buffer_height, MTLPixelFormatDepth32Float);
    };
    createFrameBuffer(canvas->handle(), 0, 0);
    Canvas::resize_callbacks.push_back(createFrameBuffer);
}

id <MTLLibrary> MetalRenderer::library() {
    return _library;
}

MTLPixelFormat MetalRenderer::colorPixelFormat() {
    return _colorPixelFormat;
}

MetalLoaderPtr MetalRenderer::resourceLoader() {
    return _metalResourceLoader;
}

id <MTLSamplerState> MetalRenderer::buildSamplerState() {
    auto *descriptor = [[MTLSamplerDescriptor alloc] init];
    descriptor.sAddressMode = MTLSamplerAddressModeRepeat;
    descriptor.tAddressMode = MTLSamplerAddressModeRepeat;
    descriptor.mipFilter = MTLSamplerMipFilterLinear;
    descriptor.maxAnisotropy = maxAnisotropy;
    return [_device newSamplerStateWithDescriptor:descriptor];
}

void MetalRenderer::begin() {
    _commandBuffer = [_commandQueue commandBuffer];
    _drawable = [_layer nextDrawable];
}

void MetalRenderer::end() {
    [_commandBuffer presentDrawable:_drawable];
    [_commandBuffer commit];
    [_commandBuffer waitUntilCompleted];
}

void MetalRenderer::activeRenderTarget(MTLRenderPassDescriptor *renderTarget) {
    if (renderTarget != nullptr) {
        _renderPassDescriptor = renderTarget;
    } else {
        _renderPassDescriptor = [MTLRenderPassDescriptor new];
        _renderPassDescriptor.colorAttachments[0].texture = _drawable.texture;
        _renderPassDescriptor.depthAttachment.texture = _depthTexture;
    }
}

void MetalRenderer::clearRenderTarget(int clearFlags,
                                      Color clearColor) {
    //TODO fix
    _renderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    _renderPassDescriptor.stencilAttachment.loadAction = MTLLoadActionClear;
    if (clearFlags == CameraClearFlags::DepthColor) {
        _renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
        _renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        _renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    }
    _renderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
    _renderPassDescriptor.stencilAttachment.storeAction = MTLStoreActionStore;
}

void MetalRenderer::beginRenderPass(MTLRenderPassDescriptor *renderTarget, Camera *camera, int mipLevel) {
    _renderEncoder = [_commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
    
    if (renderTarget != nullptr) {
        
        [_renderEncoder setViewport:MTLViewport{
            0, 0,
            2560,
            1440,
            0, 1}];
    } else {
        const auto &viewport = camera->viewport();
        int width, height;
        glfwGetFramebufferSize(_canvas->handle(), &width, &height);
        
        [_renderEncoder setViewport:MTLViewport{
            viewport.x * width,
            viewport.y * height,
            viewport.z * width,
            viewport.w * height,
            0, 1}];
    }
    
    [_renderEncoder setFragmentSamplerState:_samplerState atIndex:0];
}

void MetalRenderer::endRenderPass() {
    ImDrawData *draw_data = ImGui::GetDrawData();
    if (draw_data != nullptr) {
        [_renderEncoder pushDebugGroup:@"Dear ImGui rendering"];
        ImGui_ImplMetal_NewFrame(_renderPassDescriptor);
        ImGui_ImplMetal_RenderDrawData(draw_data, _commandBuffer, _renderEncoder);
        [_renderEncoder popDebugGroup];
    }
    
    [_renderEncoder endEncoding];
}

void MetalRenderer::synchronizeResource(id<MTLResource> resource) {
    auto blit = [_commandBuffer blitCommandEncoder];
    [blit synchronizeResource:resource];
    [blit endEncoding];
}

id<MTLTexture> MetalRenderer::mergeResource(const std::vector<id<MTLTexture>>& textures) {
    MTLTextureDescriptor* descriptor = [[MTLTextureDescriptor alloc]init];
    descriptor.textureType = MTLTextureType2DArray;
    descriptor.pixelFormat = textures[0].pixelFormat;
    descriptor.width = textures[0].width;
    descriptor.height = textures[0].height;
    descriptor.arrayLength = textures.size();
    descriptor.storageMode = MTLStorageModePrivate;
    
    auto arrayTexture = [_device newTextureWithDescriptor:descriptor];
    auto blitEncoder = [_commandBuffer blitCommandEncoder];
    MTLOrigin origin = MTLOrigin{ .x =  0, .y =  0, .z =  0};
    MTLSize size = MTLSize{.width =  arrayTexture.width,
        .height =  arrayTexture.height, .depth = 1};
    for (size_t index = 0; index < textures.size(); index++) {
        [blitEncoder copyFromTexture:textures[index] sourceSlice:0 sourceLevel:0 sourceOrigin:origin sourceSize:size
                           toTexture:arrayTexture destinationSlice:index destinationLevel:0 destinationOrigin:origin];
    }
    [blitEncoder endEncoding];
    return arrayTexture;
}

id <MTLRenderPipelineState> MetalRenderer::createRenderPipelineState(MTLRenderPipelineDescriptor *descriptor) {
    NSError *error = nil;
    auto state = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    if (error != nil)
    {
        NSLog(@"Error: failed to create Metal pipeline state: %@", error);
    }
    return state;
}

void MetalRenderer::setRenderPipelineState(id <MTLRenderPipelineState> state) {
    [_renderEncoder setRenderPipelineState:state];
}

void MetalRenderer::setRenderPipelineState(RenderPipelineState *state) {
    [_renderEncoder setRenderPipelineState:state->handle()];
}

void MetalRenderer::setVertexBuffer(id<MTLBuffer> buffer, uint32_t offset, uint32_t index) {
    [_renderEncoder setVertexBuffer:buffer offset:offset atIndex:index];
}

void MetalRenderer::setDepthStencilState(MTLDepthStencilDescriptor* depthStencilDescriptor) {
    auto depthStencilState = [_device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    [_renderEncoder setDepthStencilState:depthStencilState];
}

void MetalRenderer::setDepthStencilState(id <MTLDepthStencilState> depthStencilState) {
    [_renderEncoder setDepthStencilState:depthStencilState];
}

void MetalRenderer::setDepthBias(float depthBias, float slopeScale, float clamp) {
    [_renderEncoder setDepthBias:depthBias slopeScale:slopeScale clamp:clamp];
}

void MetalRenderer::setStencilReferenceValue(uint32_t referenceValue) {
    [_renderEncoder setStencilReferenceValue:referenceValue];
}

void MetalRenderer::setBlendColor(float red, float green, float blue, float alpha) {
    [_renderEncoder setBlendColorRed:red green:green blue:blue alpha:alpha];
}

void MetalRenderer::setCullMode(MTLCullMode cullMode) {
    [_renderEncoder setCullMode:cullMode];
}

void MetalRenderer::bindTexture(id <MTLTexture> texture, int location) {
    [_renderEncoder setFragmentTexture:texture atIndex:location];
}

void MetalRenderer::drawPrimitive(const SubMesh *subPrimitive) const {
    [_renderEncoder drawIndexedPrimitives:subPrimitive->topology
                               indexCount:subPrimitive->indexCount
                                indexType:subPrimitive->indexType
                              indexBuffer:subPrimitive->indexBuffer.buffer
                        indexBufferOffset:subPrimitive->indexBuffer.offset];
}

}
