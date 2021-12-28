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
    
    _colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB; // linear space
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
        _depthTexture = _metalResourceLoader->buildTexture(buffer_width, buffer_height, MTLPixelFormatDepth32Float_Stencil8);
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

id <MTLTexture> MetalRenderer::drawableTexture() {
    return _drawable.texture;
}

MTLPixelFormat MetalRenderer::depthStencilPixelFormat() {
    return MTLPixelFormatDepth32Float_Stencil8;
}

id <MTLTexture> MetalRenderer::depthTexture() {
    return _depthTexture;
}

id <MTLTexture> MetalRenderer::stencilTexture() {
    return _depthTexture;
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

//MARK: - Internal Render State
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
        if (renderTarget.colorAttachments[0].texture.width != 0) {
            [_renderEncoder setViewport:MTLViewport{
                0, 0,
                static_cast<double>(renderTarget.colorAttachments[0].texture.width >> mipLevel),
                static_cast<double>(renderTarget.colorAttachments[0].texture.height >> mipLevel),
                0, 1}];
        } else {
            [_renderEncoder setViewport:MTLViewport{
                0, 0,
                static_cast<double>(renderTarget.depthAttachment.texture.width >> mipLevel),
                static_cast<double>(renderTarget.depthAttachment.texture.height >> mipLevel),
                0, 1}];
        }
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

void MetalRenderer::pushDebugGroup(const std::string& groupName) {
    [_renderEncoder pushDebugGroup:[[NSString alloc]initWithUTF8String:groupName.c_str()]];
}

void MetalRenderer::popDebugGroup() {
    [_renderEncoder popDebugGroup];
}

//MARK: - MTLKit Loader
MTKMeshBufferAllocator* MetalRenderer::createBufferAllocator() {
    // Create a MetalKit mesh buffer allocator so that ModelIO will load mesh data directly into
    // Metal buffers accessible by the GPU
    return [[MTKMeshBufferAllocator alloc] initWithDevice:_device];
}

MTKMesh* MetalRenderer::convertFrom(MDLMesh *modelIOMesh) {
    NSError* error;
    // Create the metalKit mesh which will contain the Metal buffer(s) with the mesh's vertex data
    //   and submeshes with info to draw the mesh
    MTKMesh* metalKitMesh = [[MTKMesh alloc] initWithMesh:modelIOMesh
                                                   device:_device
                                                    error:&error];
    if (error != nil) {
        NSLog(@"Error: failed to create MTKMesh state: %@", error);
    }
    return metalKitMesh;
}

//MARK: - Blit Encoder
void MetalRenderer::synchronizeResource(id<MTLResource> resource) {
    auto blit = [_commandBuffer blitCommandEncoder];
    [blit synchronizeResource:resource];
    [blit endEncoding];
}

id<MTLTexture> MetalRenderer::createTextureArray(const std::vector<id<MTLTexture>>::iterator& texturesBegin,
                                                 const std::vector<id<MTLTexture>>::iterator& texturesEnd,
                                                 id<MTLTexture> packedTextures) {
    if (packedTextures == nullptr || packedTextures.arrayLength != texturesEnd - texturesBegin) {
        MTLTextureDescriptor* descriptor = [[MTLTextureDescriptor alloc]init];
        descriptor.textureType = MTLTextureType2DArray;
        descriptor.pixelFormat = (*texturesBegin).pixelFormat;
        descriptor.width = (*texturesBegin).width;
        descriptor.height = (*texturesBegin).height;
        descriptor.arrayLength = texturesEnd - texturesBegin;
        descriptor.storageMode = MTLStorageModePrivate;
        
        packedTextures = [_device newTextureWithDescriptor:descriptor];
    }
    
    auto blitEncoder = [_commandBuffer blitCommandEncoder];
    MTLOrigin origin = MTLOrigin{ .x =  0, .y =  0, .z =  0};
    MTLSize size = MTLSize{.width =  packedTextures.width,
        .height =  packedTextures.height, .depth = 1};
    for (auto iter = texturesBegin; iter < texturesEnd; iter++) {
        [blitEncoder copyFromTexture:*iter sourceSlice:0 sourceLevel:0 sourceOrigin:origin sourceSize:size
                           toTexture:packedTextures destinationSlice:iter - texturesBegin destinationLevel:0 destinationOrigin:origin];
    }
    [blitEncoder endEncoding];
    return packedTextures;
}

id<MTLTexture> MetalRenderer::createCubeTextureArray(const std::vector<id<MTLTexture>>::iterator& texturesBegin,
                                                     const std::vector<id<MTLTexture>>::iterator& texturesEnd,
                                                     id<MTLTexture> packedTextures) {
    if (packedTextures == nullptr || packedTextures.arrayLength != texturesEnd - texturesBegin) {
        MTLTextureDescriptor* descriptor = [[MTLTextureDescriptor alloc]init];
        descriptor.textureType = MTLTextureTypeCubeArray;
        descriptor.pixelFormat = (*texturesBegin).pixelFormat;
        descriptor.width = (*texturesBegin).width;
        descriptor.height = (*texturesBegin).height;
        descriptor.arrayLength = texturesEnd - texturesBegin;
        descriptor.storageMode = MTLStorageModePrivate;
        
        packedTextures = [_device newTextureWithDescriptor:descriptor];
    }
    
    int destinationSlice = 0;
    auto blitEncoder = [_commandBuffer blitCommandEncoder];
    for (auto iter = texturesBegin; iter < texturesEnd; iter++) {
        [blitEncoder copyFromTexture:*iter sourceSlice:0 sourceLevel:0
                           toTexture:packedTextures destinationSlice:destinationSlice destinationLevel:0
                          sliceCount:6 levelCount:1];
        destinationSlice += 6;
    }
    [blitEncoder endEncoding];
    return packedTextures;
}

id<MTLTexture> MetalRenderer::createAtlas(const std::array<id<MTLTexture>, 4>& textures,
                                          id<MTLTexture> packedTextures) {
    auto blitEncoder = [_commandBuffer blitCommandEncoder];
    MTLOrigin origin = MTLOrigin{ .x =  0, .y =  0, .z =  0};
    MTLOrigin sourceOrigin = origin;
    MTLSize sourceSize = MTLSize{.width =  textures[0].width,
        .height =  textures[0].height, .depth = 1};
    [blitEncoder copyFromTexture:textures[0] sourceSlice:0 sourceLevel:0 sourceOrigin:sourceOrigin sourceSize:sourceSize
                       toTexture:packedTextures destinationSlice:0 destinationLevel:0 destinationOrigin:origin];
    origin.x = textures[0].width;
    [blitEncoder copyFromTexture:textures[1] sourceSlice:0 sourceLevel:0 sourceOrigin:sourceOrigin sourceSize:sourceSize
                       toTexture:packedTextures destinationSlice:0 destinationLevel:0 destinationOrigin:origin];
    origin.x = 0;
    origin.y = textures[0].height;
    [blitEncoder copyFromTexture:textures[2] sourceSlice:0 sourceLevel:0 sourceOrigin:sourceOrigin sourceSize:sourceSize
                       toTexture:packedTextures destinationSlice:0 destinationLevel:0 destinationOrigin:origin];
    origin.x = textures[0].width;
    origin.y = textures[0].height;
    [blitEncoder copyFromTexture:textures[3] sourceSlice:0 sourceLevel:0 sourceOrigin:sourceOrigin sourceSize:sourceSize
                       toTexture:packedTextures destinationSlice:0 destinationLevel:0 destinationOrigin:origin];
    
    [blitEncoder endEncoding];
    return packedTextures;
}

id<MTLTexture> MetalRenderer::createCubeAtlas(const std::array<id<MTLTexture>, 6>& textures,
                                              id<MTLTexture> packedTextures) {
    auto blitEncoder = [_commandBuffer blitCommandEncoder];
    [blitEncoder copyFromTexture:textures[0] sourceSlice:0 sourceLevel:0
                       toTexture:packedTextures destinationSlice:0 destinationLevel:0 sliceCount:1 levelCount:1];
    [blitEncoder copyFromTexture:textures[1] sourceSlice:0 sourceLevel:0
                       toTexture:packedTextures destinationSlice:1 destinationLevel:0 sliceCount:1 levelCount:1];
    [blitEncoder copyFromTexture:textures[2] sourceSlice:0 sourceLevel:0
                       toTexture:packedTextures destinationSlice:2 destinationLevel:0 sliceCount:1 levelCount:1];
    [blitEncoder copyFromTexture:textures[3] sourceSlice:0 sourceLevel:0
                       toTexture:packedTextures destinationSlice:3 destinationLevel:0 sliceCount:1 levelCount:1];
    [blitEncoder copyFromTexture:textures[4] sourceSlice:0 sourceLevel:0
                       toTexture:packedTextures destinationSlice:4 destinationLevel:0 sliceCount:1 levelCount:1];
    [blitEncoder copyFromTexture:textures[5] sourceSlice:0 sourceLevel:0
                       toTexture:packedTextures destinationSlice:5 destinationLevel:0 sliceCount:1 levelCount:1];
    [blitEncoder endEncoding];
    return packedTextures;
}

//MARK: - Encoder State
id <MTLRenderPipelineState> MetalRenderer::createRenderPipelineState(MTLRenderPipelineDescriptor *descriptor) {
    NSError *error = nil;
    auto state = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    if (error != nil) {
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

void MetalRenderer::setFragmentTexture(id<MTLTexture> texture, uint32_t index) {
    [_renderEncoder setFragmentTexture:texture atIndex:index];
}

id <MTLDepthStencilState> MetalRenderer::createDepthStencilState(MTLDepthStencilDescriptor* depthStencilDescriptor) {
    return [_device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
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
    [_renderEncoder drawIndexedPrimitives:subPrimitive->topology()
                               indexCount:subPrimitive->indexCount
                                indexType:subPrimitive->indexType
                              indexBuffer:subPrimitive->indexBuffer.buffer
                        indexBufferOffset:subPrimitive->indexBuffer.offset];
}

void MetalRenderer::drawPrimitive(MTLPrimitiveType primitiveType,
                                  uint32_t vertexStart, uint32_t vertexCount) const {
    [_renderEncoder drawPrimitives:primitiveType vertexStart:vertexStart vertexCount:vertexCount];
}

void MetalRenderer::drawPrimitive(MTLPrimitiveType primitiveType,
                                  size_t vertexStart, size_t vertexCount, size_t instanceCount) const {
    [_renderEncoder drawPrimitives:primitiveType vertexStart:vertexStart
                       vertexCount:vertexCount instanceCount:instanceCount];
}

void MetalRenderer::drawIndexedPrimitives(MTLPrimitiveType primitiveType, size_t indexCount,
                                          MTLIndexType indexType, id<MTLBuffer> indexBuffer,
                                          size_t indexBufferOffset, size_t instanceCount) const {
    [_renderEncoder drawIndexedPrimitives:primitiveType indexCount:indexCount
                                indexType:indexType indexBuffer:indexBuffer
                        indexBufferOffset:indexBufferOffset instanceCount:instanceCount];
}

}
