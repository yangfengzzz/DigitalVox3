//
//  render_pipeline.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/24.
//

#include "forward_render_pipeline.h"
#include "../camera.h"
#include "../engine.h"
#include "../renderer.h"

namespace vox {
ForwardRenderPipeline::ForwardRenderPipeline(Camera* camera):
RenderPipeline(camera) {
    auto pass = std::make_unique<RenderPass>("default", 0, nullptr);
    _defaultPass = pass.get();
    addRenderPass(std::move(pass));
}

ForwardRenderPipeline::~ForwardRenderPipeline() {
    _renderPassArray.clear();
}

void ForwardRenderPipeline::render(RenderContext& context,
                                   std::optional<TextureCubeFace> cubeFace, int mipLevel) {
    // generate shadow map
    shadowCount = 0;
    const auto& engine = _camera->engine();
    auto& rhi = engine->_hardwareRenderer;
    
    _drawShadowMap(context);
    _drawCascadeShadowMap(context);
    if (!shadowMaps.empty()) {
        packedTexture = rhi.createTextureArray(shadowMaps.begin(), shadowMaps.begin() + shadowCount, packedTexture);
        shaderData.setData(RenderPipeline::_shadowMapProp, packedTexture);
        shaderData.setData(RenderPipeline::_shadowDataProp, shadowDatas);
    }
    
    // Composition
    _opaqueQueue.clear();
    _alphaTestQueue.clear();
    _transparentQueue.clear();
    
    _camera->engine()->_componentsManager.callRender(context, _opaqueQueue, _alphaTestQueue, _transparentQueue);
    
    std::sort(_opaqueQueue.begin(), _opaqueQueue.end(), RenderPipeline::_compareFromNearToFar);
    std::sort(_alphaTestQueue.begin(), _alphaTestQueue.end(), RenderPipeline::_compareFromNearToFar);
    std::sort(_transparentQueue.begin(), _transparentQueue.end(), RenderPipeline::_compareFromFarToNear);
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        _drawRenderPass(_renderPassArray[i].get(), _camera, cubeFace, mipLevel);
    }
}

//MARK: - RenderPass
RenderPass* ForwardRenderPipeline::defaultRenderPass() {
    return _defaultPass;
}

void ForwardRenderPipeline::addRenderPass(std::unique_ptr<RenderPass>&& pass) {
    _renderPassArray.emplace_back(std::move(pass));
    std::sort(_renderPassArray.begin(), _renderPassArray.end(),
              [](const std::unique_ptr<RenderPass>& p1, const std::unique_ptr<RenderPass>& p2){
        return p1->priority - p2->priority;
    });
}

void ForwardRenderPipeline::addRenderPass(const std::string& name,
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

void ForwardRenderPipeline::removeRenderPass(const std::string& name) {
    ssize_t index = -1;
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto& pass = _renderPassArray[i];
        if (pass->name == name) index = i;
    }
    
    if (index != -1) {
        _renderPassArray.erase(_renderPassArray.begin() + index);
    }
}

void ForwardRenderPipeline::removeRenderPass(const RenderPass* p) {
    ssize_t index = -1;
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto& pass = _renderPassArray[i];
        if (pass->name == p->name) index = i;
    }
    
    if (index != -1) {
        _renderPassArray.erase(_renderPassArray.begin() + index);
    }
}

RenderPass* ForwardRenderPipeline::getRenderPass(const std::string& name) {
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto& pass = _renderPassArray[i];
        if (pass->name == name) return pass.get();
    }
    
    return nullptr;
}

//MARK: - Internal Pipeline Method
void ForwardRenderPipeline::_drawRenderPass(RenderPass* pass, Camera* camera,
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

void ForwardRenderPipeline::_drawElement(const std::vector<RenderElement>& items, RenderPass* pass) {
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
