//
//  scene_manager.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef scene_manager_hpp
#define scene_manager_hpp

#include "scene.h"

namespace vox {
/**
 * Scene manager.
 */
class SceneManager {
public:
    /**
     * Get the activated scene.
     */
    ScenePtr activeScene();

    void setActiveScene(ScenePtr scene);
    
private:
    friend class Engine;
    
    SceneManager(Engine* engine) {}
    
    ScenePtr _activeScene;
};


}

#endif /* scene_manager_hpp */
