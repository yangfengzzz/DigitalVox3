//
//  stencil_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef stencil_state_hpp
#define stencil_state_hpp

#include <Metal/Metal.h>

namespace vox {
class MetalRenderer;

/**
 * Stencil state.
 */
struct StencilState {
    /** Whether to enable stencil test. */
    bool enabled = false;
    /** Write the reference value of the stencil buffer. */
    uint32_t referenceValue = 0;
    /** Specifying a bit-wise mask that is used to AND the reference value and the stored stencil value when the test is done. */
    uint32_t mask = 0xff;
    /** Specifying a bit mask to enable or disable writing of individual bits in the stencil planes. */
    uint32_t writeMask = 0xff;
    /** The comparison function of the reference value of the front face of the geometry and the current buffer storage value. */
    MTLCompareFunction compareFunctionFront = MTLCompareFunctionAlways;
    /** The comparison function of the reference value of the back of the geometry and the current buffer storage value. */
    MTLCompareFunction compareFunctionBack = MTLCompareFunctionAlways;
    /** specifying the function to use for front face when both the stencil test and the depth test pass. */
    MTLStencilOperation passOperationFront = MTLStencilOperationKeep;
    /** specifying the function to use for back face when both the stencil test and the depth test pass. */
    MTLStencilOperation passOperationBack = MTLStencilOperationKeep;
    /** specifying the function to use for front face when the stencil test fails. */
    MTLStencilOperation failOperationFront = MTLStencilOperationKeep;
    /** specifying the function to use for back face when the stencil test fails. */
    MTLStencilOperation failOperationBack = MTLStencilOperationKeep;
    /** specifying the function to use for front face when the stencil test passes, but the depth test fails. */
    MTLStencilOperation zFailOperationFront = MTLStencilOperationKeep;
    /** specifying the function to use for back face when the stencil test passes, but the depth test fails. */
    MTLStencilOperation zFailOperationBack = MTLStencilOperationKeep;
    
private:
    friend class RenderState;
    
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
#endif /* stencil_state_hpp */
