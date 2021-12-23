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
class ForwardRenderPipeline :public RenderPipeline {
public:
    ForwardRenderPipeline(Camera* camera);

};

}

#endif /* forward_render_pipeline_hpp */
