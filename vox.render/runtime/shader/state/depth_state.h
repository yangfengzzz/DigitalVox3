//
//  depth_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef depth_state_hpp
#define depth_state_hpp

#include <Metal/Metal.h>

namespace vox {
class MetalRenderer;

/**
 * Depth state.
 */
struct DepthState {
    /** Whether to enable the depth test. */
    bool enabled = true;
    /** Whether the depth value can be written.*/
    bool writeEnabled = true;
    /** Depth comparison function. */
    MTLCompareFunction compareFunction = MTLCompareFunctionLess;
    
private:
    friend class RenderState;
    
    /**
     * Apply the current depth state by comparing with the last depth state.
     */
    void _apply(MTLRenderPipelineDescriptor *pipelineDescriptor,
                MTLDepthStencilDescriptor *depthStencilDescriptor,
                MetalRenderer *hardwareRenderer) {
        _platformApply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer);
    }
    
    void _platformApply(MTLRenderPipelineDescriptor *pipelineDescriptor,
                        MTLDepthStencilDescriptor *depthStencilDescriptor,
                        MetalRenderer *hardwareRenderer);
};

}

#endif /* depth_state_hpp */
