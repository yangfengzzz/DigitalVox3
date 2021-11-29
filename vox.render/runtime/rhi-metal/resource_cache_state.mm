//
//  resource_cache_state.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#include "resource_cache_state.h"
#include "metal_renderer.h"
#include "maths/math_ex.h"

namespace vox {
ResourceCache::ResourceCache(MetalRenderer* render):
render(render){
    
}

ShaderProgram* ResourceCache::request_shader_module(const std::string& vertexSource, const std::string& fragmentSource,
                                                    const ShaderMacroCollection& macroInfo) {
    std::size_t hash{0U};
    math::hash_combine(hash, std::hash<std::string>{}(vertexSource));
    math::hash_combine(hash, std::hash<std::string>{}(fragmentSource));
    math::hash_combine(hash, macroInfo.hash());
    auto iter = state.shader_modules.find(hash);

    if (iter == state.shader_modules.end()) {
        state.shader_modules[hash] = std::make_unique<ShaderProgram>(render->library, vertexSource, fragmentSource, macroInfo);
        return state.shader_modules[hash].get();
    } else {
        return iter->second.get();
    }
}

RenderPipelineState* ResourceCache::request_graphics_pipeline(MTLRenderPipelineDescriptor* pipelineDescriptor) {
    const auto hash = pipelineDescriptor.hash;
    auto iter = state.graphics_pipelines.find(hash);
    if (iter == state.graphics_pipelines.end()) {
        auto pipelineState = std::make_unique<RenderPipelineState>(render, pipelineDescriptor);
        state.graphics_pipelines[hash] = std::move(pipelineState);
        return state.graphics_pipelines[hash].get();
    } else {
        return iter->second.get();
    }
}

ComputePipelineState* ResourceCache::request_compute_pipeline(MTLComputePipelineDescriptor* pipelineDescriptor) {
    const auto hash = pipelineDescriptor.hash;
    auto iter = state.compute_pipelines.find(hash);
    if (iter == state.compute_pipelines.end()) {
        auto pipelineState = std::make_unique<ComputePipelineState>(render->device, pipelineDescriptor);
        state.compute_pipelines[hash] = std::move(pipelineState);
        return state.compute_pipelines[hash].get();
    } else {
        return iter->second.get();
    }
}

void ResourceCache::clear_pipelines() {
    state.graphics_pipelines.clear();
}

void ResourceCache::clear() {
    clear_pipelines();
    state.shader_modules.clear();
}

const ResourceCacheState& ResourceCache::get_internal_state() const {
    return state;
}

}
