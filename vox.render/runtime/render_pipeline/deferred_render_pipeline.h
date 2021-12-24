//
//  defered_render_pipeline.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/24.
//

#ifndef deferred_render_pipeline_hpp
#define deferred_render_pipeline_hpp

#include "render_pipeline.h"

namespace vox {
class DeferredRenderPipeline :public RenderPipeline {
public:
    DeferredRenderPipeline(Camera* camera);
    
    ~DeferredRenderPipeline();
    
    /**
     * Perform scene rendering.
     * @param context - Render context
     * @param cubeFace - Render surface of cube texture
     * @param mipLevel - Set mip level the data want to write
     */
    void render(RenderContext& context,
                std::optional<TextureCubeFace> cubeFace = std::nullopt, int mipLevel = 0) override;
};

}

#endif /* deferred_render_pipeline_hpp */
