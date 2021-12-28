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
DeferredRenderPipeline::DeferredRenderPipeline(Camera *camera) :
RenderPipeline(camera) {
    const auto &loader = camera->engine()->resourceLoader();
    auto &rhi = camera->engine()->_hardwareRenderer;
    
    _diffuse_occlusion_GBufferFormat = MTLPixelFormatRGBA32Float;
    _specular_roughness_GBufferFormat = MTLPixelFormatRGBA32Float;
    _normal_GBufferFormat = MTLPixelFormatRGBA32Float;
    _emissive_GBufferFormat = MTLPixelFormatRGBA32Float;
    
    //MARK: - GBuffer
#pragma mark GBuffer render pass descriptor setup
    {
        // Create a render pass descriptor to create an encoder for rendering to the GBuffers.
        // The encoder stores rendered data of each attachment when encoding ends.
        _GBufferRenderPassDesc = [MTLRenderPassDescriptor new];
        
        _GBufferRenderPassDesc.colorAttachments[0].loadAction = MTLLoadActionDontCare;
        _GBufferRenderPassDesc.colorAttachments[0].storeAction = MTLStoreActionStore;
        _GBufferRenderPassDesc.colorAttachments[1].loadAction = MTLLoadActionDontCare;
        _GBufferRenderPassDesc.colorAttachments[1].storeAction = MTLStoreActionStore;
        _GBufferRenderPassDesc.colorAttachments[2].loadAction = MTLLoadActionDontCare;
        _GBufferRenderPassDesc.colorAttachments[2].storeAction = MTLStoreActionStore;
        _GBufferRenderPassDesc.depthAttachment.clearDepth = 1.0;
        _GBufferRenderPassDesc.depthAttachment.loadAction = MTLLoadActionClear;
        _GBufferRenderPassDesc.depthAttachment.storeAction = MTLStoreActionStore;
        
        _GBufferRenderPassDesc.stencilAttachment.clearStencil = 0;
        _GBufferRenderPassDesc.stencilAttachment.loadAction = MTLLoadActionClear;
        _GBufferRenderPassDesc.stencilAttachment.storeAction = MTLStoreActionStore;
        auto createFrameBuffer = [&](GLFWwindow *window, int width, int height) {
            int buffer_width, buffer_height;
            glfwGetFramebufferSize(window, &buffer_width, &buffer_height);
            MTLTextureDescriptor *GBufferTextureDesc =
            [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                               width:buffer_width
                                                              height:buffer_height
                                                           mipmapped:NO];
            GBufferTextureDesc.textureType = MTLTextureType2D;
            GBufferTextureDesc.usage |= MTLTextureUsageRenderTarget;
            GBufferTextureDesc.storageMode = MTLStorageModePrivate;
            
            GBufferTextureDesc.pixelFormat = _diffuse_occlusion_GBufferFormat;
            _diffuse_occlusion_GBuffer = loader->buildTexture(GBufferTextureDesc);
            _diffuse_occlusion_GBuffer.label = @"Diffuse + Occlusion GBuffer";
            GBufferTextureDesc.pixelFormat = _specular_roughness_GBufferFormat;
            _specular_roughness_GBuffer = loader->buildTexture(GBufferTextureDesc);
            _specular_roughness_GBuffer.label = @"Specular + Roughness GBuffer";
            GBufferTextureDesc.pixelFormat = _normal_GBufferFormat;
            _normal_GBuffer = loader->buildTexture(GBufferTextureDesc);
            _normal_GBuffer.label = @"Normal GBuffer";
            GBufferTextureDesc.pixelFormat = _emissive_GBufferFormat;
            _emissive_GBuffer = loader->buildTexture(GBufferTextureDesc);
            _emissive_GBuffer.label = @"Emissive GBuffer";
            
            _GBufferRenderPassDesc.colorAttachments[0].texture = _diffuse_occlusion_GBuffer;
            _GBufferRenderPassDesc.colorAttachments[1].texture = _specular_roughness_GBuffer;
            _GBufferRenderPassDesc.colorAttachments[2].texture = _normal_GBuffer;
            _GBufferRenderPassDesc.colorAttachments[3].texture = _emissive_GBuffer;
            _GBufferRenderPassDesc.depthAttachment.texture = rhi.depthTexture();
            _GBufferRenderPassDesc.stencilAttachment.texture = rhi.stencilTexture();
        };
        createFrameBuffer(_camera->engine()->canvas()->handle(), 0, 0);
        Canvas::resize_callbacks.push_back(createFrameBuffer);
    }
#pragma mark GBuffer render pipeline setup
    {
        _GBufferRenderPipelineDesc = [MTLRenderPipelineDescriptor new];
        _GBufferRenderPipelineDesc.label = @"G-buffer Creation";
        _GBufferRenderPipelineDesc.colorAttachments[0].pixelFormat = _diffuse_occlusion_GBufferFormat;
        _GBufferRenderPipelineDesc.colorAttachments[1].pixelFormat = _specular_roughness_GBufferFormat;
        _GBufferRenderPipelineDesc.colorAttachments[2].pixelFormat = _normal_GBufferFormat;
        _GBufferRenderPipelineDesc.colorAttachments[3].pixelFormat = _emissive_GBufferFormat;
        _GBufferRenderPipelineDesc.depthAttachmentPixelFormat = rhi.depthStencilPixelFormat();
        _GBufferRenderPipelineDesc.stencilAttachmentPixelFormat = rhi.depthStencilPixelFormat();
    }
#pragma mark GBuffer depth state setup
    {
        _GBufferStencilStateDesc = [MTLStencilDescriptor new];
        _GBufferStencilStateDesc.stencilCompareFunction = MTLCompareFunctionAlways;
        _GBufferStencilStateDesc.stencilFailureOperation = MTLStencilOperationKeep;
        _GBufferStencilStateDesc.depthFailureOperation = MTLStencilOperationKeep;
        _GBufferStencilStateDesc.depthStencilPassOperation = MTLStencilOperationReplace;
        _GBufferStencilStateDesc.readMask = 0x0;
        _GBufferStencilStateDesc.writeMask = 0xFF;
    }
    //MARK: - Compositor
#pragma mark Compositor render pass descriptor setup
    {
        // Create a render pass descriptor for thelighting and composition pass
        _finalRenderPassDesc = [MTLRenderPassDescriptor new];
        // Whatever rendered in the final pass needs to be stored so it can be displayed
        _finalRenderPassDesc.colorAttachments[0].loadAction = MTLLoadActionClear;
        _finalRenderPassDesc.colorAttachments[0].storeAction = MTLStoreActionStore;
        _finalRenderPassDesc.depthAttachment.loadAction = MTLLoadActionLoad;
        _finalRenderPassDesc.stencilAttachment.loadAction = MTLLoadActionLoad;
    }
#pragma mark Directional lighting render pipeline setup
    {
        _directionalLightPipelineDesc = [MTLRenderPipelineDescriptor new];
        _directionalLightPipelineDesc.label = @"Deferred Directional Lighting";
        _directionalLightPipelineDesc.vertexDescriptor = nil;
        _directionalLightPipelineDesc.colorAttachments[0].pixelFormat = rhi.colorPixelFormat();
        _directionalLightPipelineDesc.depthAttachmentPixelFormat = rhi.depthStencilPixelFormat();
        _directionalLightPipelineDesc.stencilAttachmentPixelFormat = rhi.depthStencilPixelFormat();
    }
#pragma mark Directional lighting mask depth stencil state setup
    {
        // Stencil state setup so direction lighting fragment shader only executed on pixels
        // drawn in GBuffer stage (i.e. mask out the background/sky)
        MTLStencilDescriptor *stencilStateDesc = [MTLStencilDescriptor new];
        stencilStateDesc.stencilCompareFunction = MTLCompareFunctionEqual;
        stencilStateDesc.stencilFailureOperation = MTLStencilOperationKeep;
        stencilStateDesc.depthFailureOperation = MTLStencilOperationKeep;
        stencilStateDesc.depthStencilPassOperation = MTLStencilOperationKeep;
        stencilStateDesc.readMask = 0xFF;
        stencilStateDesc.writeMask = 0x0;
        MTLDepthStencilDescriptor *depthStencilDesc = [MTLDepthStencilDescriptor new];
        depthStencilDesc.label = @"Deferred Directional Lighting";
        depthStencilDesc.depthWriteEnabled = NO;
        depthStencilDesc.depthCompareFunction = MTLCompareFunctionAlways;
        depthStencilDesc.frontFaceStencil = stencilStateDesc;
        depthStencilDesc.backFaceStencil = stencilStateDesc;
        _directionLightDepthStencilState = rhi.createDepthStencilState(depthStencilDesc);
    }
#pragma mark Setup icosahedron mesh for fairy light volumes
    {
        MTKMeshBufferAllocator *bufferAllocator = rhi.createBufferAllocator();
        const double unitInscribe = sqrtf(3.0) / 12.0 * (3.0 + sqrtf(5.0));
        MDLMesh *icosahedronMDLMesh = [MDLMesh newIcosahedronWithRadius:1 / unitInscribe inwardNormals:NO allocator:bufferAllocator];
        MDLVertexDescriptor *icosahedronDescriptor = [[MDLVertexDescriptor alloc] init];
        icosahedronDescriptor.attributes[0].name = MDLVertexAttributePosition;
        icosahedronDescriptor.attributes[0].format = MDLVertexFormatFloat4;
        icosahedronDescriptor.attributes[0].offset = 0;
        icosahedronDescriptor.attributes[0].bufferIndex = 0;
        icosahedronDescriptor.layouts[0].stride = sizeof(vector_float4);
        // Set the vertex descriptor to relayout vertices
        icosahedronMDLMesh.vertexDescriptor = icosahedronDescriptor;
        _icosahedronMesh = rhi.convertFrom(icosahedronMDLMesh);
    }
#pragma mark Light mask render pipeline state setup
    {
        Shader shader("Point Light Mask", "light_mask_vertex", "", "");
        ShaderProgram *program = shader.findShaderProgram(_camera->engine(), ShaderMacroCollection(), true);
        if (!program->isValid()) {
            return;
        }
        _lightMaskPipelineDesc = [MTLRenderPipelineDescriptor new];
        _lightMaskPipelineDesc.label = @"Point Light Mask";
        _lightMaskPipelineDesc.vertexDescriptor = nil;
        _lightMaskPipelineDesc.vertexFunction = program->vertexShader();
        _lightMaskPipelineDesc.fragmentFunction = nil;
        _lightMaskPipelineDesc.colorAttachments[0].pixelFormat = rhi.colorPixelFormat();
        _lightMaskPipelineDesc.depthAttachmentPixelFormat = rhi.depthStencilPixelFormat();
        _lightMaskPipelineDesc.stencilAttachmentPixelFormat = rhi.depthStencilPixelFormat();
    }
#pragma mark Light mask depth stencil state setup
    {
        MTLStencilDescriptor *stencilStateDesc = [MTLStencilDescriptor new];
        stencilStateDesc.stencilCompareFunction = MTLCompareFunctionAlways;
        stencilStateDesc.stencilFailureOperation = MTLStencilOperationKeep;
        stencilStateDesc.depthFailureOperation = MTLStencilOperationIncrementClamp;
        stencilStateDesc.depthStencilPassOperation = MTLStencilOperationKeep;
        stencilStateDesc.readMask = 0x0;
        stencilStateDesc.writeMask = 0xFF;
        MTLDepthStencilDescriptor *depthStencilDesc = [MTLDepthStencilDescriptor new];
        depthStencilDesc.label = @"Point Light Mask";
        depthStencilDesc.depthWriteEnabled = NO;
        depthStencilDesc.depthCompareFunction = MTLCompareFunctionLessEqual;
        depthStencilDesc.frontFaceStencil = stencilStateDesc;
        depthStencilDesc.backFaceStencil = stencilStateDesc;
        _lightMaskDepthStencilState = rhi.createDepthStencilState(depthStencilDesc);
    }
#pragma mark Point light render pipeline setup
    {
        Shader shader("Point Light", "deferred_point_lighting_vertex", "", "deferred_point_lighting_fragment_traditional");
        ShaderProgram *program = shader.findShaderProgram(_camera->engine(), ShaderMacroCollection(), true);
        if (!program->isValid()) {
            return;
        }
        _lightPipelineDesc = [MTLRenderPipelineDescriptor new];
        // Enable additive blending
        _lightPipelineDesc.colorAttachments[0].blendingEnabled = YES;
        _lightPipelineDesc.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
        _lightPipelineDesc.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
        _lightPipelineDesc.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOne;
        _lightPipelineDesc.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOne;
        _lightPipelineDesc.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorOne;
        _lightPipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorOne;
        _lightPipelineDesc.colorAttachments[0].pixelFormat = rhi.colorPixelFormat();
        _lightPipelineDesc.depthAttachmentPixelFormat = rhi.depthStencilPixelFormat();
        _lightPipelineDesc.stencilAttachmentPixelFormat = rhi.depthStencilPixelFormat();
        _lightPipelineDesc.label = @"Light";
        _lightPipelineDesc.vertexFunction = program->vertexShader();
        _lightPipelineDesc.fragmentFunction = program->fragmentShader();
    }
#pragma mark Point light depth state setup
    {
        MTLStencilDescriptor *stencilStateDesc = [MTLStencilDescriptor new];
        stencilStateDesc.stencilCompareFunction = MTLCompareFunctionLess;
        stencilStateDesc.stencilFailureOperation = MTLStencilOperationKeep;
        stencilStateDesc.depthFailureOperation = MTLStencilOperationKeep;
        stencilStateDesc.depthStencilPassOperation = MTLStencilOperationKeep;
        stencilStateDesc.readMask = 0xFF;
        stencilStateDesc.writeMask = 0x0;
        MTLDepthStencilDescriptor *depthStencilDesc = [MTLDepthStencilDescriptor new];
        depthStencilDesc.depthWriteEnabled = NO;
        depthStencilDesc.depthCompareFunction = MTLCompareFunctionLessEqual;
        depthStencilDesc.frontFaceStencil = stencilStateDesc;
        depthStencilDesc.backFaceStencil = stencilStateDesc;
        depthStencilDesc.label = @"Point Light";
        _pointLightDepthStencilState = rhi.createDepthStencilState(depthStencilDesc);
    }
#pragma mark Fairy billboard render pipeline setup
    {
        Shader shader("Fairy Drawing", "fairy_vertex", "fairy_fragment", "");
        ShaderProgram *program = shader.findShaderProgram(_camera->engine(), ShaderMacroCollection());
        if (!program->isValid()) {
            return;
        }
        _fairyPipelineDesc = [MTLRenderPipelineDescriptor new];
        _fairyPipelineDesc.label = @"Fairy Drawing";
        _fairyPipelineDesc.vertexDescriptor = nil;
        _fairyPipelineDesc.vertexFunction = program->vertexShader();
        _fairyPipelineDesc.fragmentFunction = program->fragmentShader();
        _fairyPipelineDesc.colorAttachments[0].pixelFormat = rhi.colorPixelFormat();
        _fairyPipelineDesc.depthAttachmentPixelFormat = rhi.depthStencilPixelFormat();
        _fairyPipelineDesc.stencilAttachmentPixelFormat = rhi.depthStencilPixelFormat();
        _fairyPipelineDesc.colorAttachments[0].blendingEnabled = YES;
        _fairyPipelineDesc.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
        _fairyPipelineDesc.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
        _fairyPipelineDesc.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
        _fairyPipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
        _fairyPipelineDesc.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOne;
        _fairyPipelineDesc.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOne;
    }
#pragma mark Post lighting depth state setup
    {
        MTLDepthStencilDescriptor *depthStencilDesc = [MTLDepthStencilDescriptor new];
        depthStencilDesc.label = @"Less -Writes";
        depthStencilDesc.depthCompareFunction = MTLCompareFunctionLess;
        depthStencilDesc.depthWriteEnabled = NO;
        _dontWriteDepthStencilState = rhi.createDepthStencilState(depthStencilDesc);
    }
#pragma mark Setup 2D circle mesh for fairy billboards
    {
        Float2 fairyVertices[7];
        const float angle = 2 * M_PI / (float) 7;
        for (int vtx = 0; vtx < 7; vtx++) {
            int point = (vtx % 2) ? (vtx + 1) / 2 : -vtx / 2;
            fairyVertices[vtx] = Float2(sin(point * angle), cos(point * angle));
        }
        _fairy = loader->buildBuffer(fairyVertices, sizeof(fairyVertices), NULL);
        _fairy.label = @"Fairy Vertices";
    }
#pragma mark Load textures for non-mesh assets
    {
        _fairyMap = loader->loadTexture("../models/", "fairy.png");
        _fairyMap.label = @"Fairy Map";
    }
}

DeferredRenderPipeline::~DeferredRenderPipeline() {
    
}

void DeferredRenderPipeline::_drawRenderPass(RenderPass *pass, Camera *camera,
                                             std::optional<TextureCubeFace> cubeFace,
                                             int mipLevel) {
    pass->preRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
    
    if (pass->enabled) {
        const auto &engine = camera->engine();
        const auto &scene = camera->scene();
        const auto &background = scene->background;
        auto &rhi = engine->_hardwareRenderer;
        
        //MARK: - GBuffer
        rhi.activeRenderTarget(_GBufferRenderPassDesc);
        rhi.beginRenderPass(_GBufferRenderPassDesc, camera, mipLevel);
        if (pass->renderOverride) {
            pass->render(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
        } else {
            _drawElement(_opaqueQueue, pass);
        }
        rhi.endRenderPass();// renderEncoder
        
        //MARK: -  Composition
        const auto &color = pass->clearColor != std::nullopt ? pass->clearColor.value() : background.solidColor;
        _finalRenderPassDesc.colorAttachments[0].clearColor = MTLClearColorMake(color.r, color.g, color.b, 1.0);
        _finalRenderPassDesc.colorAttachments[0].texture = rhi.drawableTexture();
        _finalRenderPassDesc.depthAttachment.texture = rhi.depthTexture();
        _finalRenderPassDesc.stencilAttachment.texture = rhi.stencilTexture();
        
        rhi.activeRenderTarget(_finalRenderPassDesc);
        rhi.beginRenderPass(_finalRenderPassDesc, camera, mipLevel);
        _drawDirectionalLights();
        size_t numPointLights = scene->light_manager.pointLights().size();
        if (numPointLights > 0) {
            _drawPointLightMask(numPointLights);
            _drawPointLights(numPointLights);
            if (_openDebugger) {
                _drawFairies(numPointLights);
            }
        }
        rhi.endRenderPass();// renderEncoder
    }
    
    pass->postRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
}

void DeferredRenderPipeline::_drawElement(const std::vector<RenderElement> &items,
                                          RenderPass *pass) {
    if (items.size() == 0) {
        return;
    }
    
    const auto &engine = _camera->engine();
    const auto &scene = _camera->scene();
    auto &rhi = engine->_hardwareRenderer;
    const auto &sceneData = scene->shaderData;
    const auto &cameraData = _camera->shaderData;
    
    //MARK:- Start Render
    for (size_t i = 0; i < items.size(); i++) {
        const auto &item = items[i];
        const auto &renderPassFlag = item.component->entity()->layer;
        
        if ((renderPassFlag & pass->mask) == 0) {
            continue;
        }
        
        // RenderElement
        auto compileMacros = ShaderMacroCollection();
        const auto &element = item;
        const auto &renderer = element.component;
        auto material = pass->material(element);
        if (material == nullptr) {
            material = element.material;
        }
        auto &rendererData = renderer->shaderData;
        const auto &materialData = material->shaderData;
        
        if (renderer->receiveShadow && shadowCount != 0) {
            rendererData.enableMacro(SHADOW_MAP_COUNT, std::make_pair(shadowCount, MTLDataTypeInt));
        }
        
        if (renderer->receiveShadow && cubeShadowCount != 0) {
            rendererData.enableMacro(CUBE_SHADOW_MAP_COUNT, std::make_pair(cubeShadowCount, MTLDataTypeInt));
        }
        
        // union render global macro and material self macro.
        materialData.mergeMacro(renderer->_globalShaderMacro, compileMacros);
        
        //MARK:- Set Pipeline State
        ShaderProgram *program = material->shader->findShaderProgram(engine, compileMacros, true);
        if (!program->isValid()) {
            continue;
        }
        
        _GBufferRenderPipelineDesc.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh->vertexDescriptor());
        _GBufferRenderPipelineDesc.vertexFunction = program->vertexShader();
        _GBufferRenderPipelineDesc.fragmentFunction = program->fragmentShader();
        
        MTLDepthStencilDescriptor *depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
        material->renderState._apply(engine, _GBufferRenderPipelineDesc, depthStencilDescriptor);
        depthStencilDescriptor.frontFaceStencil = _GBufferStencilStateDesc;
        depthStencilDescriptor.backFaceStencil = _GBufferStencilStateDesc;
        auto depthStencilState = rhi.createDepthStencilState(depthStencilDescriptor);
        rhi.setDepthStencilState(depthStencilState);
        rhi.setStencilReferenceValue(128);
        
        const auto &pipelineState = rhi.resouceCache.request_graphics_pipeline(_GBufferRenderPipelineDesc);
        rhi.setRenderPipelineState(pipelineState);
        
        //MARK:- Load Resouces
        pipelineState->uploadAll(pipelineState->sceneUniformBlock, sceneData);
        pipelineState->uploadAll(pipelineState->cameraUniformBlock, cameraData);
        pipelineState->uploadAll(pipelineState->rendererUniformBlock, rendererData);
        pipelineState->uploadAll(pipelineState->materialUniformBlock, materialData);
        pipelineState->uploadAll(pipelineState->internalUniformBlock, shaderData);
        
        auto &buffers = element.mesh->_vertexBuffer;
        for (uint32_t index = 0; index < buffers.size(); index++) {
            rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
        }
        rhi.drawPrimitive(element.subMesh);
    }
}

void DeferredRenderPipeline::_drawDirectionalLights() {
    const auto &engine = _camera->engine();
    auto &rhi = engine->_hardwareRenderer;
    const auto &cameraData = _camera->shaderData;
    const auto &scene = _camera->scene();
    const auto &sceneData = scene->shaderData;
    auto compileMacros = scene->_globalShaderMacro;
    Shader shader("Deferred Directional Lighting", "deferred_direction_lighting_vertex", "",
                  "deferred_directional_lighting_fragment_traditional");
    ShaderProgram *program = shader.findShaderProgram(engine, compileMacros, true);
    if (!program->isValid()) {
        return;
    }
    
    _directionalLightPipelineDesc.vertexFunction = program->vertexShader();
    _directionalLightPipelineDesc.fragmentFunction = program->fragmentShader();
    const auto &pipelineState = rhi.resouceCache.request_graphics_pipeline(_directionalLightPipelineDesc);
    rhi.setRenderPipelineState(pipelineState);
    
    rhi.setCullMode(MTLCullModeBack);
    rhi.setStencilReferenceValue(128);
    rhi.setDepthStencilState(_directionLightDepthStencilState);
    rhi.setFragmentTexture(_diffuse_occlusion_GBuffer, 0);
    rhi.setFragmentTexture(_specular_roughness_GBuffer, 1);
    rhi.setFragmentTexture(_normal_GBuffer, 2);
    rhi.setFragmentTexture(_emissive_GBuffer, 3);
    rhi.setFragmentTexture(rhi.depthTexture(), 4);
    
    pipelineState->uploadAll(pipelineState->sceneUniformBlock, sceneData);
    pipelineState->uploadAll(pipelineState->cameraUniformBlock, cameraData);
    
    rhi.drawPrimitive(MTLPrimitiveTypeTriangle, 0, 6);
}

void DeferredRenderPipeline::_drawPointLightMask(size_t numPointLights) {
    const auto &engine = _camera->engine();
    auto &rhi = engine->_hardwareRenderer;
    const auto &cameraData = _camera->shaderData;
    const auto &scene = _camera->scene();
    const auto &sceneData = scene->shaderData;
    
    rhi.pushDebugGroup("Draw Light Mask");
    const auto &pipelineState = rhi.resouceCache.request_graphics_pipeline(_lightMaskPipelineDesc);
    rhi.setRenderPipelineState(pipelineState);
    rhi.setDepthStencilState(_lightMaskDepthStencilState);
    rhi.setStencilReferenceValue(128);
    rhi.setCullMode(MTLCullModeBack);
    pipelineState->uploadAll(pipelineState->sceneUniformBlock, sceneData);
    pipelineState->uploadAll(pipelineState->cameraUniformBlock, cameraData);
    
    MTKMeshBuffer *vertexBuffer = _icosahedronMesh.vertexBuffers[0];
    rhi.setVertexBuffer(vertexBuffer.buffer, static_cast<uint32_t>(vertexBuffer.offset), 0);
    MTKSubmesh *icosahedronSubmesh = _icosahedronMesh.submeshes[0];
    rhi.drawIndexedPrimitives(icosahedronSubmesh.primitiveType, icosahedronSubmesh.indexCount,
                              icosahedronSubmesh.indexType, icosahedronSubmesh.indexBuffer.buffer,
                              icosahedronSubmesh.indexBuffer.offset, numPointLights);
    
    rhi.popDebugGroup();
}

void DeferredRenderPipeline::_drawPointLights(size_t numPointLights) {
    const auto &engine = _camera->engine();
    auto &rhi = engine->_hardwareRenderer;
    const auto &cameraData = _camera->shaderData;
    const auto &scene = _camera->scene();
    const auto &sceneData = scene->shaderData;
    
    rhi.pushDebugGroup("Draw Point Lights");
    const auto &pipelineState = rhi.resouceCache.request_graphics_pipeline(_lightPipelineDesc);
    rhi.setRenderPipelineState(pipelineState);
    rhi.setFragmentTexture(_diffuse_occlusion_GBuffer, 0);
    rhi.setFragmentTexture(_specular_roughness_GBuffer, 1);
    rhi.setFragmentTexture(_normal_GBuffer, 2);
    rhi.setFragmentTexture(_emissive_GBuffer, 3);
    rhi.setFragmentTexture(rhi.depthTexture(), 4);
    
    rhi.setDepthStencilState(_pointLightDepthStencilState);
    rhi.setStencilReferenceValue(128);
    rhi.setCullMode(MTLCullModeFront);
    pipelineState->uploadAll(pipelineState->sceneUniformBlock, sceneData);
    pipelineState->uploadAll(pipelineState->cameraUniformBlock, cameraData);
    
    MTKMeshBuffer *vertexBuffer = _icosahedronMesh.vertexBuffers[0];
    rhi.setVertexBuffer(vertexBuffer.buffer, static_cast<uint32_t>(vertexBuffer.offset), 0);
    MTKSubmesh *icosahedronSubmesh = _icosahedronMesh.submeshes[0];
    rhi.drawIndexedPrimitives(icosahedronSubmesh.primitiveType, icosahedronSubmesh.indexCount,
                              icosahedronSubmesh.indexType, icosahedronSubmesh.indexBuffer.buffer,
                              icosahedronSubmesh.indexBuffer.offset, numPointLights);
    
    rhi.popDebugGroup();
}

void DeferredRenderPipeline::_drawFairies(size_t numPointLights) {
    const auto &engine = _camera->engine();
    auto &rhi = engine->_hardwareRenderer;
    const auto &cameraData = _camera->shaderData;
    const auto &scene = _camera->scene();
    const auto &sceneData = scene->shaderData;
    
    rhi.pushDebugGroup("Draw Fairies");
    const auto &pipelineState = rhi.resouceCache.request_graphics_pipeline(_fairyPipelineDesc);
    rhi.setRenderPipelineState(pipelineState);
    rhi.setDepthStencilState(_dontWriteDepthStencilState);
    rhi.setCullMode(MTLCullModeBack);
    pipelineState->uploadAll(pipelineState->sceneUniformBlock, sceneData);
    pipelineState->uploadAll(pipelineState->cameraUniformBlock, cameraData);
    rhi.setVertexBuffer(_fairy, 0, 0);
    rhi.setFragmentTexture(_fairyMap, 0);
    
    rhi.drawPrimitive(MTLPrimitiveTypeTriangleStrip, 0, 7, numPointLights);
    rhi.popDebugGroup();
}

}
