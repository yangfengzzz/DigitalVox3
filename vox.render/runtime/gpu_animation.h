//
//  gpu_animation.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/16.
//

#ifndef gpu_animation_hpp
#define gpu_animation_hpp

#include "component.h"
#include "../maths/vec_float.h"
#include <vector>
#include <string>

namespace vox {
class GPUAnimation: public Component {
public:
    struct AnimationChannel {
        enum PathType { TRANSLATION, ROTATION, SCALE };
        PathType path;
        Entity* node;
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
    
    GPUAnimation(Entity* entity);
    
    void update(float deltaTime);
    
private:
    std::vector<AnimationSampler> samplers;
    std::vector<AnimationChannel> channels;
    float start = std::numeric_limits<float>::max();
    float end = std::numeric_limits<float>::min();
};

}

#endif /* gpu_animation_hpp */
