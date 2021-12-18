//
//  compute_pipeline_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#ifndef compute_pipeline_state_hpp
#define compute_pipeline_state_hpp

#import <Metal/Metal.h>
#include "../vox_type.h"

namespace vox {
class ComputePipelineState {
public:
    ComputePipelineState(MetalRenderer* _render, MTLComputePipelineDescriptor* descriptor);

    id<MTLComputePipelineState> handle();
        
private:
    MetalRenderer *_render;
    id<MTLComputePipelineState> _handle;
};

}

#endif /* compute_pipeline_state_hpp */
