//
//  basic_render_pipeline.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "basic_render_pipeline.h"
#include "../material/material.h"
#include "../lighting/light.h"
#include "../camera.h"
#include "../engine.h"
#include "../renderer.h"

namespace vox {
bool BasicRenderPipeline::_compareFromNearToFar(const RenderElement& a, const RenderElement& b) {
    return (a.material->renderQueueType < b.material->renderQueueType) ||
    (a.component->_distanceForSort < b.component->_distanceForSort) ||
    (b.component->_renderSortId < a.component->_renderSortId);
}

bool BasicRenderPipeline::_compareFromFarToNear(const RenderElement& a, const RenderElement& b) {
    return (a.material->renderQueueType < b.material->renderQueueType) ||
    (b.component->_distanceForSort < a.component->_distanceForSort) ||
    (b.component->_renderSortId < a.component->_renderSortId);
}

//MARK: - RenderElement
BasicRenderPipeline::BasicRenderPipeline(Camera* camera):
_camera(camera) {
    auto pass = std::make_unique<RenderPass>("default", 0, nullptr);
    _defaultPass = pass.get();
    addRenderPass(std::move(pass));
}

void BasicRenderPipeline::destroy() {
    _opaqueQueue.clear();
    _alphaTestQueue.clear();
    _transparentQueue.clear();
    _renderPassArray.clear();
}

void BasicRenderPipeline::render(RenderContext& context,
                                 std::optional<TextureCubeFace> cubeFace, int mipLevel) {
    // generate shadow map
    _drawShadowMap(context);
    
    // Composition
    _opaqueQueue.clear();
    _alphaTestQueue.clear();
    _transparentQueue.clear();
    
    _camera->engine()->_componentsManager.callRender(context, _opaqueQueue, _alphaTestQueue, _transparentQueue);
    
    std::sort(_opaqueQueue.begin(), _opaqueQueue.end(), BasicRenderPipeline::_compareFromNearToFar);
    std::sort(_alphaTestQueue.begin(), _alphaTestQueue.end(), BasicRenderPipeline::_compareFromNearToFar);
    std::sort(_transparentQueue.begin(), _transparentQueue.end(), BasicRenderPipeline::_compareFromFarToNear);
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        _drawRenderPass(_renderPassArray[i].get(), _camera, cubeFace, mipLevel);
    }
}

//MARK: - RenderPass
RenderPass* BasicRenderPipeline::defaultRenderPass() {
    return _defaultPass;
}

void BasicRenderPipeline::addRenderPass(std::unique_ptr<RenderPass>&& pass) {
    _renderPassArray.emplace_back(std::move(pass));
    std::sort(_renderPassArray.begin(), _renderPassArray.end(),
              [](const std::unique_ptr<RenderPass>& p1, const std::unique_ptr<RenderPass>& p2){
        return p1->priority - p2->priority;
    });
}

void BasicRenderPipeline::addRenderPass(const std::string& name,
                                        int priority,
                                        MTLRenderPassDescriptor* renderTarget,
                                        Layer mask) {
    auto renderPass = std::make_unique<RenderPass>(name, priority, renderTarget, mask);
    _renderPassArray.emplace_back(std::move(renderPass));
    std::sort(_renderPassArray.begin(), _renderPassArray.end(),
              [](const std::unique_ptr<RenderPass>& p1, const std::unique_ptr<RenderPass>& p2){
        return p1->priority - p2->priority;
    });
}

void BasicRenderPipeline::removeRenderPass(const std::string& name) {
    ssize_t index = -1;
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto& pass = _renderPassArray[i];
        if (pass->name == name) index = i;
    }
    
    if (index != -1) {
        _renderPassArray.erase(_renderPassArray.begin() + index);
    }
}

void BasicRenderPipeline::removeRenderPass(const RenderPass* p) {
    ssize_t index = -1;
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto& pass = _renderPassArray[i];
        if (pass->name == p->name) index = i;
    }
    
    if (index != -1) {
        _renderPassArray.erase(_renderPassArray.begin() + index);
    }
}

RenderPass* BasicRenderPipeline::getRenderPass(const std::string& name) {
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto& pass = _renderPassArray[i];
        if (pass->name == name) return pass.get();
    }
    
    return nullptr;
}

//MARK: - Internal Pipeline Method
void BasicRenderPipeline::_drawRenderPass(RenderPass* pass, Camera* camera,
                                          std::optional<TextureCubeFace> cubeFace, int mipLevel) {
    pass->preRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
    
    if (pass->enabled) {
        const auto& engine = camera->engine();
        const auto& scene = camera->scene();
        const auto& background = scene->background;
        auto& rhi = engine->_hardwareRenderer;
        
        // prepare to load render target
        MTLRenderPassDescriptor* renderTarget;
        if (camera->renderTarget() != nullptr) {
            renderTarget = camera->renderTarget();
        } else {
            renderTarget = pass->renderTarget;
        }
        rhi.activeRenderTarget(renderTarget);
        // set clear flag
        const auto& clearFlags = pass->clearFlags != std::nullopt ? pass->clearFlags.value(): camera->clearFlags;
        const auto& color = pass->clearColor != std::nullopt? pass->clearColor.value(): background.solidColor;
        if (clearFlags != CameraClearFlags::None) {
            rhi.clearRenderTarget(clearFlags, color);
        }
        
        // command encoder
        rhi.beginRenderPass(renderTarget, camera, mipLevel);
        if (pass->renderOverride) {
            pass->render(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
        } else {
            _drawElement(_opaqueQueue, pass);
            _drawElement(_alphaTestQueue, pass);
            if (background.mode == BackgroundMode::Sky) {
                _drawSky(background.sky);
            }
            _drawElement(_transparentQueue, pass);
        }
        
        // poseprocess
        
        rhi.endRenderPass();// renderEncoder
    }
    
    pass->postRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
}

void BasicRenderPipeline::_drawElement(const std::vector<RenderElement>& items, RenderPass* pass) {
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
        const auto& rendererData = renderer->shaderData;
        const auto& materialData = material->shaderData;
        
        // union render global macro and material self macro.
        materialData.mergeMacro(renderer->_globalShaderMacro, compileMacros);
        
        //MARK:- Set Pipeline State
        ShaderProgram* program = material->shader->findShaderProgram(engine, compileMacros);
        if (!program->isValid()) {
            continue;
        }
        
        MTLRenderPipelineDescriptor* descriptor = [[MTLRenderPipelineDescriptor alloc]init];
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh->vertexDescriptor());
        descriptor.vertexFunction = program->vertexShader();
        descriptor.fragmentFunction = program->fragmentShader();
        
        descriptor.colorAttachments[0].pixelFormat = engine->_hardwareRenderer.colorPixelFormat();
        descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
        
        MTLDepthStencilDescriptor* depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc]init];
        material->renderState._apply(engine, descriptor, depthStencilDescriptor);
        rhi.setDepthStencilState(depthStencilDescriptor);
        
        const auto& pipelineState = rhi.resouceCache.request_graphics_pipeline(descriptor);
        rhi.setRenderPipelineState(pipelineState);
        
        //MARK:- Load Resouces
        pipelineState->groupingOtherUniformBlock();
        pipelineState->uploadAll(pipelineState->sceneUniformBlock, sceneData);
        pipelineState->uploadAll(pipelineState->cameraUniformBlock, cameraData);
        pipelineState->uploadAll(pipelineState->rendererUniformBlock, rendererData);
        pipelineState->uploadAll(pipelineState->materialUniformBlock, materialData);
        
        auto& buffers = element.mesh->_vertexBuffer;
        for (uint32_t index = 0; index < buffers.size(); index++) {
            rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
        }
        rhi.drawPrimitive(element.subMesh);
    }
}

void BasicRenderPipeline::_drawSky(const Sky& sky) {
    const auto& material = sky.material;
    const auto& mesh = sky.mesh;
    if (!material) {
        std::cerr << "The material of sky is not defined." << std::endl;
        return;
    }
    if (!mesh) {
        std::cerr << "The mesh of sky is not defined." << std::endl;
        return;
    }
    
    const auto& engine = _camera->engine();
    auto& rhi = engine->_hardwareRenderer;
    auto& shaderData = material->shaderData;
    
    auto compileMacros = ShaderMacroCollection();
    shaderData.mergeMacro(_camera->_globalShaderMacro, compileMacros);
    
    const auto projectionMatrix = _camera->projectionMatrix();
    auto _matrix = _camera->viewMatrix();
    _matrix.elements[12] = 0;
    _matrix.elements[13] = 0;
    _matrix.elements[14] = 0;
    _matrix.elements[15] = 1;
    _matrix = projectionMatrix * _matrix;
    shaderData.setData("u_mvpNoscale", _matrix);
    
    auto program = material->shader->findShaderProgram(engine, compileMacros);
    if (!program->isValid()) {
        return;
    }
    
    auto descriptor = [[MTLRenderPipelineDescriptor alloc]init];
    descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh->vertexDescriptor());
    descriptor.vertexFunction = program->vertexShader();
    descriptor.fragmentFunction = program->fragmentShader();
    
    descriptor.colorAttachments[0].pixelFormat = engine->_hardwareRenderer.colorPixelFormat();
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    auto depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc]init];
    material->renderState._apply(engine, descriptor, depthStencilDescriptor);
    rhi.setDepthStencilState(depthStencilDescriptor);
    
    auto pipelineState = rhi.resouceCache.request_graphics_pipeline(descriptor);
    rhi.setRenderPipelineState(pipelineState);
    
    pipelineState->groupingOtherUniformBlock();
    pipelineState->uploadAll(pipelineState->materialUniformBlock, shaderData);
    
    auto& buffers = mesh->_vertexBuffer;
    for (uint32_t index = 0; index < buffers.size(); index++) {
        rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
    }
    rhi.drawPrimitive(mesh->subMesh(0));
}

void BasicRenderPipeline::_drawShadowMap(RenderContext& context) {
    const auto& engine = _camera->engine();
    auto& rhi = engine->_hardwareRenderer;
    
    std::vector<id<MTLTexture>> shadowMaps;
    const auto& lights = context.scene()->light_manager.visibleLights();
    for (const auto& light : lights) {
        if (light->enableShadow()) {
            auto texture = rhi.resourceLoader()->buildTexture(light->shadow.mapSizeX,
                                                              light->shadow.mapSizeY,
                                                              MTLPixelFormatDepth32Float);
            MTLRenderPassDescriptor* shadowRenderPassDescriptor = [[MTLRenderPassDescriptor alloc]init];
            shadowRenderPassDescriptor.depthAttachment.texture = texture;
            shadowRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
            shadowRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
            shadowRenderPassDescriptor.depthAttachment.clearDepth = 1;
            rhi.beginRenderPass(shadowRenderPassDescriptor, _camera, 0);
            
            MTLDepthStencilDescriptor* depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc]init];
            depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
            depthStencilDescriptor.depthWriteEnabled = true;
            rhi.setDepthStencilState(depthStencilDescriptor);
            rhi.setCullMode(MTLCullModeNone);
            rhi.setDepthBias(0.01, 1.0, 0.01);
            
            MDLVertexDescriptor* vertexDescriptor = [[MDLVertexDescriptor alloc]init];
            vertexDescriptor.attributes[0] = [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributePosition
                                                                              format:MDLVertexFormatFloat3
                                                                              offset:0 bufferIndex:0];
            vertexDescriptor.layouts[0] = [[MDLVertexBufferLayout alloc]initWithStride:12];
            MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc]init];
            pipelineDescriptor.vertexFunction = [rhi.library() newFunctionWithName:@"vertex_depth"];
            pipelineDescriptor.fragmentFunction = NULL;
            pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatInvalid;
            pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor);
            pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
            auto state = rhi.createRenderPipelineState(pipelineDescriptor);
            rhi.setRenderPipelineState(state);
            
            std::vector<RenderElement> opaqueQueue{};
            std::vector<RenderElement> transparentQueue{};
            std::vector<RenderElement> alphaTestQueue{};
            auto viewMatrix = invert(light->entity()->transform->worldMatrix());
            auto projMatrix = light->shadowProjectionMatrix();
            BoundingFrustum frustum;
            frustum.calculateFromMatrix(projMatrix * viewMatrix);
            engine->_componentsManager.callRender(frustum, opaqueQueue, alphaTestQueue, transparentQueue);

            for (const auto& element : opaqueQueue) {
                if (element.component->castShadow) {
                    auto& buffers = element.mesh->_vertexBuffer;
                    for (uint32_t index = 0; index < buffers.size(); index++) {
                        rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
                    }
                    rhi.drawPrimitive(element.subMesh);
                }
            }
            
            // render loop
            rhi.endRenderPass();
            shadowMaps.push_back(texture);
        }
    }
    if (!shadowMaps.empty()) {
        rhi.resourceLoader()->createTextureArray(shadowMaps);
    }
}

}
