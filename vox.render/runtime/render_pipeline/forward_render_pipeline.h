//
//  render_pipeline.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/24.
//

#ifndef forward_render_pipeline_hpp
#define forward_render_pipeline_hpp

#include "render_pipeline.h"

namespace vox {
class ForwardRenderPipeline : public RenderPipeline {
public:
    ForwardRenderPipeline(Camera *camera);
    
    ~ForwardRenderPipeline();
    
private:
    void _drawRenderPass(RenderPass *pass, Camera *camera,
                         std::optional<TextureCubeFace> cubeFace = std::nullopt,
                         int mipLevel = 0) override;
    
    void _drawElement(const std::vector<RenderElement> &renderQueue, RenderPass *pass);
};

}

#endif /* forward_render_pipeline_hpp */
