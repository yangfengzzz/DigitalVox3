//
//  render_pipeline_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_pipeline_state_hpp
#define render_pipeline_state_hpp

#import <Metal/Metal.h>

namespace vox {
class MetalRenderer;

class RenderPipelineState {
public:
    id <MTLRenderPipelineState> handle() {
        return _handle;
    }
    
    MTLRenderPipelineReflection *reflection() {
        return _reflection;
    }
    
private:
    MetalRenderer *_render;
    MTLRenderPipelineReflection *_reflection;
    id <MTLRenderPipelineState> _handle;
};

}

#endif /* render_pipeline_state_hpp */
