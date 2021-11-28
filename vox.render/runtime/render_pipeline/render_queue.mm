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

void RenderQueue::render(Camera* camera, MaterialPtr replaceMaterial, Layer mask) {
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

        if ((renderPassFlag & mask) == 0) {
            continue;
        }

        // RenderElement
        auto compileMacros = ShaderMacroCollection();
        const auto& element = item;
        const auto& renderer = element.component;
        const auto& material = (replaceMaterial != nil) ? replaceMaterial : element.material;
        const auto& rendererData = renderer->shaderData;
        const auto& materialData = material->shaderData;

        // @todo: temporary solution
        // material->_preRender(element);

        // union render global macro and material self macro.
        ShaderMacroCollection::unionCollection(
                renderer->_globalShaderMacro,
                materialData._macroCollection,
                compileMacros);

        //MARK:- Set Pipeline State
        ShaderProgram* program = material->shader->_getShaderProgram(engine, compileMacros);
        if (!program->isValid()) {
            continue;
        }

        MTLRenderPipelineDescriptor* descriptor = [[MTLRenderPipelineDescriptor alloc]init];
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh->_vertexDescriptor);
        descriptor.vertexFunction = program->vertexShader();
        descriptor.fragmentFunction = program->fragmentShader();
        
        descriptor.colorAttachments[0].pixelFormat = engine->_hardwareRenderer.colorPixelFormat;
        descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
        
        MTLDepthStencilDescriptor* depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc]init];
        material->renderState._apply(engine, descriptor, depthStencilDescriptor);
        
        const auto& pipelineState = rhi.resouceCache.request_graphics_pipeline(descriptor);
        rhi.setRenderPipelineState(pipelineState);
        
        const auto& depthStencilState = [engine->_hardwareRenderer.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
        rhi.setDepthStencilState(depthStencilState);
        
        //MARK:- Load Resouces
        pipelineState->groupingOtherUniformBlock();
        pipelineState->uploadAll(pipelineState->sceneUniformBlock, sceneData);
        pipelineState->uploadAll(pipelineState->cameraUniformBlock, cameraData);
        pipelineState->uploadAll(pipelineState->rendererUniformBlock, rendererData);
        pipelineState->uploadAll(pipelineState->materialUniformBlock, materialData);

        auto& buffers = element.mesh->_vertexBuffer;
        for (size_t index = 0; index < buffers.size(); index++) {
            [rhi.renderEncoder setVertexBuffer:buffers[index]->buffer() offset:0 atIndex:index];
        }
        rhi.drawPrimitive(element.subMesh);
    }
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
