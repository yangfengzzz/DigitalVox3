//
//  basic_render_pipeline.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "basic_render_pipeline.h"
#include "../camera.h"
#include "../material/material.h"
#include "../engine.h"
#include "../lighting/light.h"

namespace vox {
BasicRenderPipeline::BasicRenderPipeline(Camera* camera):
_camera(camera),
_opaqueQueue(RenderQueue(camera->engine())),
_alphaTestQueue(RenderQueue(camera->engine())),
_transparentQueue(RenderQueue(camera->engine())){
    auto pass = std::make_unique<RenderPass>("default", 0, nullptr);
    _defaultPass = pass.get();
    addRenderPass(std::move(pass));
}

void BasicRenderPipeline::destroy() {
    _opaqueQueue.destroy();
    _alphaTestQueue.destroy();
    _transparentQueue.destroy();
    _renderPassArray.clear();
}

void BasicRenderPipeline::clearRenderQueue() {
    _opaqueQueue.clear();
    _alphaTestQueue.clear();
    _transparentQueue.clear();
}

void BasicRenderPipeline::render(const RenderContext& context,
                                 std::optional<TextureCubeFace> cubeFace, int mipLevel) {
    const auto& lights = context.scene()->light_manager.visibleLights();
    for (const auto& light : lights) {
        if (light->enableShadow()) {
            
        }
    }
    
    _opaqueQueue.sort(RenderQueue::_compareFromNearToFar);
    _alphaTestQueue.sort(RenderQueue::_compareFromNearToFar);
    _transparentQueue.sort(RenderQueue::_compareFromFarToNear);
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        _drawRenderPass(_renderPassArray[i].get(), _camera, cubeFace, mipLevel);
    }
}

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
            _opaqueQueue.render(camera, pass);
            _alphaTestQueue.render(camera, pass);
            if (background.mode == BackgroundMode::Sky) {
                _alphaTestQueue.drawSky(engine, camera, background.sky);
            }
            _transparentQueue.render(camera, pass);
        }
        rhi.endRenderPass();
    }
    
    pass->postRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
}

void BasicRenderPipeline::pushPrimitive(const RenderElement& element) {
    const auto renderQueueType = element.material->renderQueueType;
    
    if (renderQueueType > (RenderQueueType::Transparent + RenderQueueType::AlphaTest) >> 1) {
        _transparentQueue.pushPrimitive(element);
    } else if (renderQueueType > (RenderQueueType::AlphaTest + RenderQueueType::Opaque) >> 1) {
        _alphaTestQueue.pushPrimitive(element);
    } else {
        _opaqueQueue.pushPrimitive(element);
    }
}

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

}
