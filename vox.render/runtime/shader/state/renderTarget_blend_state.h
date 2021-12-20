//
//  renderTarget_blend_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef renderTarget_blend_state_hpp
#define renderTarget_blend_state_hpp

#include <Metal/Metal.h>

namespace vox {
/**
 * The blend state of the render target.
 */
struct RenderTargetBlendState {
    /** Whether to enable blend. */
    bool enabled = false;
    /** color (RGB) blend operation. */
    MTLBlendOperation colorBlendOperation = MTLBlendOperationAdd;
    /** alpha (A) blend operation. */
    MTLBlendOperation alphaBlendOperation = MTLBlendOperationAdd;
    /** color blend factor (RGB) for source. */
    MTLBlendFactor sourceColorBlendFactor = MTLBlendFactorOne;
    /** alpha blend factor (A) for source. */
    MTLBlendFactor sourceAlphaBlendFactor = MTLBlendFactorOne;
    /** color blend factor (RGB) for destination. */
    MTLBlendFactor destinationColorBlendFactor = MTLBlendFactorZero;
    /** alpha blend factor (A) for destination. */
    MTLBlendFactor destinationAlphaBlendFactor = MTLBlendFactorZero;
    /** color mask. */
    MTLColorWriteMask colorWriteMask = MTLColorWriteMaskAll;
};

}

#endif /* renderTarget_blend_state_hpp */
