//
//  scene_animation_clip.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/17.
//

#include "scene_animation_clip.h"
#include <iostream>

namespace vox {
SceneAnimationClip::SceneAnimationClip(const std::string &name) :
_name(name) {
}

const std::string &SceneAnimationClip::name() const {
    return _name;
}

void SceneAnimationClip::update(float deltaTime) {
    _currentTime += deltaTime;
    if (_currentTime > _end) {
        _currentTime -= _end;
    }
    
    for (auto &channel: _channels) {
        AnimationSampler &sampler = _samplers[channel.samplerIndex];
        for (size_t i = 0; i < sampler.inputs.size() - 1; i++) {
            if (sampler.interpolation != AnimationSampler::LINEAR) {
                std::cout << "This sample only supports linear interpolations\n";
                continue;
            }
            
            // Get the input keyframe values for the current time stamp
            if ((_currentTime >= sampler.inputs[i]) && (_currentTime <= sampler.inputs[i + 1])) {
                float a = (_currentTime - sampler.inputs[i]) / (sampler.inputs[i + 1] - sampler.inputs[i]);
                if (channel.path == AnimationChannel::TRANSLATION) {
                    channel.node->transform->setPosition(Lerp(sampler.outputsVec4[i], sampler.outputsVec4[i + 1], a).xyz());
                }
                if (channel.path == AnimationChannel::ROTATION) {
                    Quaternion q1;
                    q1.x = sampler.outputsVec4[i].x;
                    q1.y = sampler.outputsVec4[i].y;
                    q1.z = sampler.outputsVec4[i].z;
                    q1.w = sampler.outputsVec4[i].w;
                    
                    Quaternion q2;
                    q2.x = sampler.outputsVec4[i + 1].x;
                    q2.y = sampler.outputsVec4[i + 1].y;
                    q2.z = sampler.outputsVec4[i + 1].z;
                    q2.w = sampler.outputsVec4[i + 1].w;
                    
                    channel.node->transform->setRotationQuaternion(Normalize(SLerp(q1, q2, a)));
                }
                if (channel.path == AnimationChannel::SCALE) {
                    channel.node->transform->setScale(Lerp(sampler.outputsVec4[i], sampler.outputsVec4[i + 1], a).xyz());
                }
            }
        }
    }
}

float SceneAnimationClip::start() const {
    return _start;
}

void SceneAnimationClip::setStart(float time) {
    _start = time;
}

float SceneAnimationClip::end() const {
    return _end;
}

void SceneAnimationClip::setEnd(float time) {
    _end = time;
}

void SceneAnimationClip::addSampler(const AnimationSampler &sampler) {
    _samplers.push_back(sampler);
}

void SceneAnimationClip::addChannel(const AnimationChannel &channel) {
    _channels.push_back(channel);
}

}
