//
//  animator.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#ifndef animator_hpp
#define animator_hpp

#include "component.h"
#include "animation/animation.h"
#include "animation/sampling_job.h"
#include "animation/blending_job.h"
#include "animator_controller.h"
#include "../containers/vector.h"
#include "../memory/unique_ptr.h"
#include "maths/soa_transform.h"
#include <string>

namespace vox {
class Animator: public Component {
public:
    // Sampler structure contains all the data required to sample a single
    // animation.
    struct AnimationClip {
        // Constructor, default initialization.
        AnimationClip() : weight(1.f) {}

        // Playback animation controller. This is a utility class that helps with
        // controlling animation playback time.
        vox::AnimatorController controller;

        // Blending weight for the layer.
        float weight;

        // Runtime animation.
        vox::animation::Animation animation;

        // Sampling cache.
        vox::animation::SamplingCache cache;

        // Buffer of local transforms as sampled from animation_.
        vox::vector<vox::math::SoaTransform> locals;
    };
    
    Animator(Entity* entity);
    
    bool addAnimationClip(const std::string& filename, int num_joints, int num_soa_joints);
    
    void update(float deltaTime);
    
    span<vox::animation::BlendingJob::Layer> layers();
    
private:
    void _onEnable() override;

    void _onDisable() override;

private:
    friend class ComponentsManager;
    
    ssize_t _onUpdateIndex = -1;
    vox::vector<vox::unique_ptr<AnimationClip>> clips_;
    vox::vector<vox::animation::BlendingJob::Layer> layers_;
};

}

#endif /* animator_hpp */
