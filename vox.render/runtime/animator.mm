//
//  animator.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#include "animator.h"
#include "engine.h"
#include "mesh/skinned_mesh_renderer.h"
#include "../offline/anim_loader.h"
#include <string>

namespace vox {
Animator::Animator(Entity *entity) :
Component(entity) {
}

bool Animator::addAnimationClip(const std::string &filename) {
    const auto skinnedMesh = entity()->getComponent<SkinnedMeshRenderer>();
    if (skinnedMesh) {
        return addAnimationClip(filename, skinnedMesh->numJoints(), skinnedMesh->numSoaJoints());
    } else {
        assert(false && "found no skeleton");
    }
}

bool Animator::addAnimationClip(const std::string &filename, int num_joints, int num_soa_joints) {
    vox::unique_ptr<AnimationClip> clip = vox::make_unique<AnimationClip>();
    
    if (!vox::offline::loader::LoadAnimation(filename.c_str(), &clip->animation)) {
        return false;
    }
    
    // Allocates sampler runtime buffers.
    clip->locals.resize(num_soa_joints);
    
    // Allocates a cache that matches animation requirements.
    clip->cache.Resize(num_joints);
    
    clips_.emplace_back(std::move(clip));
    layers_.resize(clips_.size());
    
    return true;
}

void Animator::update(float deltaTime) {
    size_t kNumLayers = clips_.size();
    
    // Updates and samples all animations to their respective local space
    // transform buffers.
    for (int i = 0; i < kNumLayers; ++i) {
        AnimationClip *clip = clips_[i].get();
        
        // Updates animations time.
        clip->controller.Update(clip->animation, deltaTime);
        
        // Early out if this sampler weight makes it irrelevant during blending.
        if (clips_[i]->weight <= 0.f) {
            continue;
        }
        
        // Setup sampling job.
        vox::animation::SamplingJob sampling_job;
        sampling_job.animation = &clip->animation;
        sampling_job.cache = &clip->cache;
        sampling_job.ratio = clip->controller.time_ratio();
        sampling_job.output = make_span(clip->locals);
        
        // Samples animation.
        if (!sampling_job.Run()) {
            return;
        }
    }
    
    for (int i = 0; i < kNumLayers; ++i) {
        layers_[i].transform = make_span(clips_[i]->locals);
        layers_[i].weight = clips_[i]->weight;
    }
}

span<vox::animation::BlendingJob::Layer> Animator::layers() {
    return make_span(layers_);
}

void Animator::_onEnable() {
    engine()->_componentsManager.addOnUpdateAnimators(this);
}

void Animator::_onDisable() {
    engine()->_componentsManager.removeOnUpdateAnimators(this);
}

}
