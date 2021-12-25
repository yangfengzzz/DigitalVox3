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
    _depth_GBufferFormat = MTLPixelFormatDepth32Float_Stencil8;
    
    _renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];
    _renderPipelineDescriptor.label = @"G-buffer Creation";
    _renderPipelineDescriptor.colorAttachments[0].pixelFormat = _albedo_specular_GBufferFormat;
    _renderPipelineDescriptor.colorAttachments[1].pixelFormat = _normal_shadow_GBufferFormat;
    _renderPipelineDescriptor.depthAttachmentPixelFormat = _depth_GBufferFormat;
    _renderPipelineDescriptor.stencilAttachmentPixelFormat = _depth_GBufferFormat;

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
        _depth_GBuffer = loader->buildTexture(GBufferTextureDesc);
        _depth_GBuffer.label = @"Depth GBuffer";
        
        _GBufferRenderPassDescriptor.colorAttachments[0].texture = _albedo_specular_GBuffer;
        _GBufferRenderPassDescriptor.colorAttachments[1].texture = _normal_shadow_GBuffer;
        _GBufferRenderPassDescriptor.depthAttachment.texture = _depth_GBuffer;
        _GBufferRenderPassDescriptor.stencilAttachment.texture = _depth_GBuffer;
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
        
        //MARK: - GBuffer
        rhi.activeRenderTarget(_GBufferRenderPassDescriptor);
        // command encoder
        rhi.beginRenderPass(_GBufferRenderPassDescriptor, camera, mipLevel);
        if (pass->renderOverride) {
            pass->render(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
        } else {
            _drawElement(_opaqueQueue, pass);
        }
        rhi.endRenderPass();// renderEncoder
        
        //MARK: -  Composition
        _finalRenderPassDescriptor.colorAttachments[0].texture = rhi.drawableTexture();
        _finalRenderPassDescriptor.depthAttachment.texture = rhi.depthTexture();
        _finalRenderPassDescriptor.stencilAttachment.texture = rhi.stencilTexture();
        
        rhi.activeRenderTarget(_finalRenderPassDescriptor);
        // set clear flag
        const auto& clearFlags = pass->clearFlags != std::nullopt ? pass->clearFlags.value(): camera->clearFlags;
        const auto& color = pass->clearColor != std::nullopt? pass->clearColor.value(): background.solidColor;
        if (clearFlags != CameraClearFlags::None) {
            rhi.clearRenderTarget(clearFlags, color);
        }
        // command encoder
        rhi.beginRenderPass(_finalRenderPassDescriptor, camera, mipLevel);
        rhi.endRenderPass();// renderEncoder
    }
    
    pass->postRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
}

void DeferredRenderPipeline::_drawElement(const std::vector<RenderElement>& items,
                                          RenderPass* pass) {
    if (items.size() == 0) {
        return;
    }
    
    const auto& engine = _camera->engine();
    const auto& scene = _camera->scene();
    auto& rhi = engine->_hardwareRenderer;
    const auto& sceneData = scene->shaderData;
    const auto& cameraData = _camera->shaderData;
    
    //MARK:- Start Render
    for (size_t i = 0; i < items.size(); i++) {
        const auto& item = items[i];
        const auto& renderPassFlag = item.component->entity()->layer;
        
        if ((renderPassFlag & pass->mask) == 0) {
            continue;
        }
        
        // RenderElement
        auto compileMacros = ShaderMacroCollection();
        const auto& element = item;
        const auto& renderer = element.component;
        auto material = pass->material(element);
        if (material == nullptr) {
            material = element.material;
        }
        auto& rendererData = renderer->shaderData;
        const auto& materialData = material->shaderData;
        
        if (renderer->receiveShadow && shadowCount != 0) {
            rendererData.enableMacro(SHADOW_MAP_COUNT, std::make_pair(shadowCount, MTLDataTypeInt));
        }
        
        if (renderer->receiveShadow && cubeShadowCount != 0) {
            rendererData.enableMacro(CUBE_SHADOW_MAP_COUNT, std::make_pair(cubeShadowCount, MTLDataTypeInt));
        }
        
        // union render global macro and material self macro.
        materialData.mergeMacro(renderer->_globalShaderMacro, compileMacros);
        
        //MARK:- Set Pipeline State
        ShaderProgram* program = material->shader->findShaderProgram(engine, compileMacros);
        if (!program->isValid()) {
            continue;
        }
        
        _renderPipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh->vertexDescriptor());
        _renderPipelineDescriptor.vertexFunction = program->vertexShader();
        _renderPipelineDescriptor.fragmentFunction = program->fragmentShader();

        MTLDepthStencilDescriptor* depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc]init];
        material->renderState._apply(engine, _renderPipelineDescriptor, depthStencilDescriptor);
        rhi.setDepthStencilState(depthStencilDescriptor);
        
        const auto& pipelineState = rhi.resouceCache.request_graphics_pipeline(_renderPipelineDescriptor);
        rhi.setRenderPipelineState(pipelineState);
        
        //MARK:- Load Resouces
        pipelineState->uploadAll(pipelineState->sceneUniformBlock, sceneData);
        pipelineState->uploadAll(pipelineState->cameraUniformBlock, cameraData);
        pipelineState->uploadAll(pipelineState->rendererUniformBlock, rendererData);
        pipelineState->uploadAll(pipelineState->materialUniformBlock, materialData);
        pipelineState->uploadAll(pipelineState->internalUniformBlock, shaderData);
        
        auto& buffers = element.mesh->_vertexBuffer;
        for (uint32_t index = 0; index < buffers.size(); index++) {
            rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
        }
        rhi.drawPrimitive(element.subMesh);
    }
}

}
