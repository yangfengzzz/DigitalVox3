//
//  compute_pipeline_state.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#include "compute_pipeline_state.h"
#include "metal_renderer.h"

namespace vox {
ComputePipelineState::ComputePipelineState(MetalRenderer *_render, MTLComputePipelineDescriptor *descriptor) :
_render(_render) {
    MTLComputePipelineReflection *_reflection;
    NSError *error = nil;
    _handle = [_render->_device newComputePipelineStateWithDescriptor:descriptor
                                                              options:MTLPipelineOptionArgumentInfo
                                                           reflection:&_reflection error:&error];
    if (error != nil) {
        NSLog(@"Error: failed to create Metal pipeline state: %@", error);
    }
}

id <MTLComputePipelineState> ComputePipelineState::handle() {
    return _handle;
}

}
