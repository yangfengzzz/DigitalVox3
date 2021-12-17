//
//  scene_animator.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/16.
//

#include "scene_animator.h"

namespace vox {
SceneAnimator::SceneAnimator(Entity* entity):
Component(entity) {}

void SceneAnimator::update(float deltaTime) {
    
}

float SceneAnimator::start() {
    return _start;
}

void SceneAnimator::setStart(float time) {
    _start = time;
}

float SceneAnimator::end() {
    return _end;
}

void SceneAnimator::setEnd(float time) {
    _end = time;
}

void SceneAnimator::addSampler(const AnimationSampler& sampler) {
    _samplers.push_back(sampler);
}

void SceneAnimator::addChannel(const AnimationChannel& channel) {
    _channels.push_back(channel);
}


}
