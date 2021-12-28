//
//  scene_animator.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/16.
//

#ifndef scene_animator_hpp
#define scene_animator_hpp

#include "component.h"
#include "scene_animation/scene_animation_clip.h"
#include <vector>
#include <string>

namespace vox {
class SceneAnimator : public Component {
public:
    SceneAnimator(Entity *entity);
    
    void update(float deltaTime);
    
    void addAnimationClip(std::unique_ptr<SceneAnimationClip> &&clip);
    
    void play(const std::string &name);
    
private:
    void _onEnable() override;
    
    void _onDisable() override;
    
private:
    friend class ComponentsManager;
    
    ssize_t _onUpdateIndex = -1;
    ssize_t _activeAnimation = -1;
    std::vector<std::unique_ptr<SceneAnimationClip>> _animationClips;
};

}

#endif /* scene_animator_hpp */
