//
//  compute_pipeline_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#ifndef compute_pipeline_state_hpp
#define compute_pipeline_state_hpp

#import <Metal/Metal.h>

namespace vox {
class ComputePipelineState {
public:
    ComputePipelineState(id<MTLDevice> device, MTLComputePipelineDescriptor* descriptor);

    id<MTLComputePipelineState> handle();
    
    MTLAutoreleasedComputePipelineReflection* reflection();
    
private:
    MTLAutoreleasedComputePipelineReflection* _reflection;
    id<MTLComputePipelineState> _handle;
};

}

#endif /* compute_pipeline_state_hpp */
