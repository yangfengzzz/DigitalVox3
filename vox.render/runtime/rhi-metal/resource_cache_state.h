//
//  resource_cache_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#ifndef resource_cache_state_hpp
#define resource_cache_state_hpp

#include "../vox_type.h"
#include "../shader/shader_macro_collection.h"
#include "render_pipeline_state.h"

#include <unordered_map>
#include <string>
#include <Metal/Metal.h>

namespace vox {

/// Struct to hold the internal state of the Resource Cache
struct ResourceCacheState {
    std::unordered_map<size_t, std::unique_ptr<ShaderProgram>> shader_modules;

    std::unordered_map<size_t, std::unique_ptr<RenderPipelineState>> graphics_pipelines;
    
    std::unordered_map<size_t, std::unique_ptr<RenderPass>> render_passes;
};

/// Cache all sorts of Metal objects specific to a Metal device.
/// Supports serialization and deserialization of cached resources.
/// There is only one cache for all these objects, with several unordered_map of hash indices
/// and objects. For every object requested, there is a templated version on request_resource.
/// Some objects may need building if they are not found in the cache.
///
/// The resource cache is also linked with ResourceRecord and ResourceReplay. Replay can warm-up
/// the cache on app startup by creating all necessary objects.
/// The cache holds pointers to objects and has a mapping from such pointers to hashes.
/// It can only be destroyed in bulk, single elements cannot be removed.
class ResourceCache {
public:
    MetalRenderer* render;
    ResourceCacheState state;
    
    ResourceCache(MetalRenderer* render);
    
    ShaderProgram* request_shader_module(const std::string& vertexSource, const std::string& fragmentSource,
                                         ShaderMacroCollection& macroInfo);
    
    RenderPipelineState* request_graphics_pipeline(MTLRenderPipelineDescriptor* pipelineDescriptor);
    
    void clear_pipelines();

    void clear();
    
    const ResourceCacheState& get_internal_state() const;
};

}

#endif /* resource_cache_state_hpp */
