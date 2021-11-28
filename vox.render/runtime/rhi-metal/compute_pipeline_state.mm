//
//  compute_pipeline_state.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#include "compute_pipeline_state.h"

namespace vox {
ComputePipelineState::ComputePipelineState(id<MTLDevice> device, MTLComputePipelineDescriptor* descriptor) {
    _handle = [device newComputePipelineStateWithDescriptor:descriptor
                                                    options:MTLPipelineOptionArgumentInfo
                                                 reflection:_reflection error:nullptr];
}

id<MTLComputePipelineState> ComputePipelineState::handle() {
    return _handle;
}

MTLAutoreleasedComputePipelineReflection* ComputePipelineState::reflection() {
    return _reflection;
}

}
