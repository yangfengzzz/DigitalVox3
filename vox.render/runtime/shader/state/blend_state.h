//
//  blend_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef blend_state_hpp
#define blend_state_hpp

#include "renderTarget_blend_state.h"
#include "maths/color.h"

namespace vox {
using namespace math;
class MetalRenderer;

/// Blend state.
struct BlendState {
    /// The blend state of the render target.
    RenderTargetBlendState targetBlendState = RenderTargetBlendState();
    /// Constant blend color.
    Color blendColor = Color(0, 0, 0, 0);
    /// Whether to use (Alpha-to-Coverage) technology.
    bool alphaToCoverage = false;
    
private:
    friend class RenderState;
    
    void _apply(MTLRenderPipelineDescriptor* pipelineDescriptor,
                MTLDepthStencilDescriptor* depthStencilDescriptor,
                MetalRenderer* hardwareRenderer) {
        _platformApply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer);
    }

    void _platformApply(MTLRenderPipelineDescriptor* pipelineDescriptor,
                        MTLDepthStencilDescriptor* depthStencilDescriptor,
                        MetalRenderer* hardwareRenderer);
};

}

#endif /* blend_state_hpp */
