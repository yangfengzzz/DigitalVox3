//
//  render_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_state_hpp
#define render_state_hpp

#include "../../vox_type.h"
#include "blend_state.h"
#include "raster_state.h"
#include "depth_state.h"
#include "stencil_state.h"

namespace vox {
/**
 * Render state.
 */
struct RenderState {
    /** Blend state. */
    BlendState blendState = BlendState();
    /** Depth state. */
    DepthState depthState = DepthState();
    /** Stencil state. */
    StencilState stencilState = StencilState();
    /** Raster state. */
    RasterState rasterState = RasterState();
    
private:
    friend class RenderPipeline;
    
    friend class ForwardRenderPipeline;
    
    friend class DeferredRenderPipeline;
    
    void _apply(Engine *engine,
                MTLRenderPipelineDescriptor *pipelineDescriptor,
                MTLDepthStencilDescriptor *depthStencilDescriptor);
};

}

#endif /* render_state_hpp */
