//
//  scene_manager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "scene_manager.h"

namespace vox {
ScenePtr SceneManager::activeScene() {
    return _activeScene;
}

void SceneManager::setActiveScene(ScenePtr newValue) {
    auto oldScene = _activeScene;
    if (oldScene != newValue) {
        if (oldScene) {
            oldScene->_processActive(false);
        }
        if (newValue) {
            newValue->_processActive(true);
        }
        _activeScene = newValue;
    }
}

}
