//
//  engine.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "engine.h"
#include "camera.h"
#include "log.h"

namespace vox {
void Engine::run() {
    resume();
}

void Engine::resume() {
    if (!_isPaused) return;
    _isPaused = false;
    timer().reset();
    
    while (!_canvas.shouldClose()) {
        update();
    }
}

void Engine::update() {
    const auto deltaTime = _timer.tick();
    
    const auto& scene = _sceneManager._activeScene;
    if (scene) {
        _componentsManager.callScriptOnStart();
        
        _componentsManager.callScriptOnUpdate(deltaTime);
        // _componentsManager.callAnimationUpdate(deltaTime);
        _componentsManager.callScriptOnLateUpdate(deltaTime);
        
        _render(scene);
    }
}

void Engine::_render(ScenePtr scene) {
    const auto& cameras = scene->_activeCameras;
    
    if (cameras.size() > 0) {
        for (size_t i = 0, l = cameras.size(); i < l; i++) {
            const auto& camera = cameras[i];
            const auto& cameraEntity = camera->entity();
            if (camera->enabled() && cameraEntity->isActiveInHierarchy()) {
                camera->render();
            }
        }
    } else {
        log::Err() << "NO active camera." << std::endl;
    }
}

}
