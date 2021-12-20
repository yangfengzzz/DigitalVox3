//
//  render_queue.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "render_queue.h"
#include "../material/material.h"
#include "../renderer.h"
#include "../camera.h"
#include "../engine.h"
#include "../scene.h"
#include "../graphics/mesh.h"
#include <MetalKit/MetalKit.h>

namespace vox {
RenderQueue::RenderQueue(Engine* engine) {
    
}

void RenderQueue::pushPrimitive(RenderElement element) {
    items.push_back(element);
}

void RenderQueue::render(Camera* camera, RenderPass* pass) {
    if (items.size() == 0) {
        return;
    }
    
    const auto& engine = camera->engine();
    const auto& scene = camera->scene();
    auto& rhi = engine->_hardwareRenderer;
    const auto& sceneData = scene->shaderData;
    const auto& cameraData = camera->shaderData;
    
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

void RenderQueue::drawSky(Engine* engine, Camera* camera, const Sky& sky) {
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
    
    auto& rhi = engine->_hardwareRenderer;
    auto& shaderData = material->shaderData;
    
    auto compileMacros = ShaderMacroCollection();
    shaderData.mergeMacro(camera->_globalShaderMacro, compileMacros);
    
    const auto projectionMatrix = camera->projectionMatrix();
    auto _matrix = camera->viewMatrix();
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

void RenderQueue::clear() {
    items.clear();
}

void RenderQueue::destroy() {
    
}

void RenderQueue::sort(std::function<bool(const RenderElement&, const RenderElement&)> compareFunc) {
    std::sort(items.begin(), items.end(), compareFunc);
}

bool RenderQueue::_compareFromNearToFar(const RenderElement& a, const RenderElement& b) {
    return (a.material->renderQueueType < b.material->renderQueueType) ||
    (a.component->_distanceForSort < b.component->_distanceForSort) ||
    (b.component->_renderSortId < a.component->_renderSortId);
}

bool RenderQueue::_compareFromFarToNear(const RenderElement& a, const RenderElement& b) {
    return (a.material->renderQueueType < b.material->renderQueueType) ||
    (b.component->_distanceForSort < a.component->_distanceForSort) ||
    (b.component->_renderSortId < a.component->_renderSortId);
}

}
