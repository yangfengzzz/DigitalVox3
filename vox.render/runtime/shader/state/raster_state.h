//
//  raster_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef raster_state_hpp
#define raster_state_hpp

#include <Metal/Metal.h>

namespace vox {
class MetalRenderer;

/**
 * Raster state.
 */
struct RasterState {
    /** Specifies whether or not front- and/or back-facing polygons can be culled. */
    MTLCullMode cullMode = MTLCullModeFront;
    /** The multiplier by which an implementation-specific value is multiplied with to create a constant depth offset. */
    float depthBias = 0;
    /** The scale factor for the variable depth offset for each polygon. */
    float slopeScaledDepthBias = 0;
    
private:
    friend class RenderState;
    
    bool _cullFaceEnable = true;
    
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

#endif /* raster_state_hpp */
