//
//  basic_render_pipeline.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "basic_render_pipeline.h"
#include "../camera.h"

namespace vox {
BasicRenderPipeline::BasicRenderPipeline(Camera* camera):
_camera(camera),
_opaqueQueue(RenderQueue(camera->engine())),
_alphaTestQueue(RenderQueue(camera->engine())),
_transparentQueue(RenderQueue(camera->engine())){
    _defaultPass = RenderPass("default", 0, nullptr, nullptr);
    addRenderPass(_defaultPass);
}

void BasicRenderPipeline::destroy() {
    _opaqueQueue.destroy();
    _alphaTestQueue.destroy();
    _transparentQueue.destroy();
    _renderPassArray.clear();
}

}
