//
//  defered_render_pipeline.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/24.
//

#include "deferred_render_pipeline.h"

namespace vox {
DeferredRenderPipeline::DeferredRenderPipeline(Camera* camera):
RenderPipeline(camera) {
}

DeferredRenderPipeline::~DeferredRenderPipeline() {
    
}

void DeferredRenderPipeline::render(RenderContext& context,
                                    std::optional<TextureCubeFace> cubeFace, int mipLevel) {
    
}

}
