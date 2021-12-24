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
        
        // command encoder
        if (pass->renderOverride) {
            pass->render(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
        } else {
            if (background.mode == BackgroundMode::Sky) {
                _drawSky(background.sky);
            }
        }
        
        rhi.endRenderPass();// renderEncoder
    }
    
    pass->postRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
}

}
