//
//  scene_animator.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/16.
//

#include "scene_animator.h"
#include "entity.h"
#include "engine.h"
#include <iostream>

namespace vox {
SceneAnimator::SceneAnimator(Entity *entity) :
Component(entity) {
}

void SceneAnimator::update(float deltaTime) {
    if (_activeAnimation != -1) {
        _animationClips[_activeAnimation]->update(deltaTime);
    }
}

void SceneAnimator::addAnimationClip(std::unique_ptr<SceneAnimationClip> &&clip) {
    _animationClips.emplace_back(std::move(clip));
}

void SceneAnimator::play(const std::string &name) {
    auto iter = std::find_if(_animationClips.begin(), _animationClips.end(), [&](const auto &u) {
        return u->name() == name;
    });
    if (iter != _animationClips.end()) {
        _activeAnimation = iter - _animationClips.begin();
    } else {
        _activeAnimation = -1;
    }
}

void SceneAnimator::_onEnable() {
    engine()->_componentsManager.addOnUpdateSceneAnimators(this);
}

void SceneAnimator::_onDisable() {
    engine()->_componentsManager.removeOnUpdateSceneAnimators(this);
}

}
