//
//  scene_animator.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/16.
//

#ifndef scene_animator_hpp
#define scene_animator_hpp

#include "component.h"
#include "../maths/vec_float.h"
#include <vector>
#include <string>

namespace vox {
class SceneAnimator: public Component {
public:
    struct AnimationChannel {
        enum PathType { TRANSLATION, ROTATION, SCALE };
        PathType path;
        EntityPtr node;
        uint32_t samplerIndex;
    };

    struct AnimationSampler {
        enum InterpolationType { LINEAR, STEP, CUBICSPLINE };
        InterpolationType interpolation;
        std::vector<float> inputs;
        std::vector<math::Float4> outputsVec4;
    };
    
public:
    std::string name;
    
    SceneAnimator(Entity* entity);
    
    void update(float deltaTime);
    
    float start();
    
    void setStart(float time);
    
    float end();
    
    void setEnd(float time);
    
    void addSampler(const AnimationSampler& sampler);
    
    void addChannel(const AnimationChannel& channel);
    
private:
    std::vector<AnimationSampler> _samplers;
    std::vector<AnimationChannel> _channels;
    float _start = std::numeric_limits<float>::max();
    float _end = std::numeric_limits<float>::min();
    
    float _currentTime = 0.0f;
};

}

#endif /* scene_animator_hpp */
