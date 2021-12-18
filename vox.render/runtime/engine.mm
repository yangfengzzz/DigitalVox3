//
//  engine.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "engine.h"
#include "camera.h"
#include "log.h"
#include "../gui/imgui_impl_glfw.h"
#include "material/material.h"
#include "shader/shader_pool.h"

namespace vox {
Engine::Engine(Canvas* canvas):_canvas(canvas), _hardwareRenderer(canvas) {
    ShaderPool::initialization();
    _sceneManager.setActiveScene(std::make_shared<Scene>(this, "DefaultScene"));
}

Engine::~Engine() {
    // -- cancel animation
    pause();
}

Canvas* Engine::canvas() {
    return _canvas;
}

SceneManager Engine::sceneManager() {
    return _sceneManager;
}

MetalLoaderPtr Engine::resourceLoader() {
    return _hardwareRenderer.resourceLoader();
}

Timer Engine::timer() {
    return _timer;
}

bool Engine::isPaused() {
    return _isPaused;
}

int Engine::vSyncCount() {
    return _vSyncCount;
}

void Engine::setVSyncCount(int newValue) {
    _vSyncCount = std::max(0, newValue);
}

float Engine::targetFrameRate() {
    return _targetFrameRate;
}

void Engine::setTargetFrameRate(float newValue) {
    newValue = std::max(0.000001f, newValue);
    _targetFrameRate = newValue;
    _targetFrameInterval = 1000 / newValue;
}

void Engine::run() {
    resume();
}

void Engine::pause() {
    _isPaused = true;
}

void Engine::resume() {
    if (!_isPaused) return;
    _isPaused = false;
    timer().reset();
    
    while (!_canvas->shouldClose()) {
        update();
    }
}

void Engine::update() {
    const float deltaTime = _timer.tick();
    
    const auto& scene = _sceneManager._activeScene;
    if (scene) {
        std::sort(scene->_activeCameras.begin(), scene->_activeCameras.end(),
                  [](const Camera* camera1, const Camera* camera2){
            return camera1->priority - camera2->priority;
        });
        
        _componentsManager.callScriptOnStart();
        
        _physicsManager.callColliderOnUpdate();
        _physicsManager.update(deltaTime);
        _physicsManager.callColliderOnLateUpdate();
        _physicsManager.callCharacterControllerOnLateUpdate();
        
        glfwPollEvents();
        ImGui_ImplGlfw_NewFrame();
        
        _componentsManager.callScriptOnUpdate(deltaTime);
        _componentsManager.callAnimatorUpdate(deltaTime);
        _componentsManager.callSceneAnimatorUpdate(deltaTime);
        _componentsManager.callScriptOnLateUpdate(deltaTime);
        
        _hardwareRenderer.begin();
        _render(scene, deltaTime);
        _hardwareRenderer.end();
        _componentsManager.callScriptOnEndFrame();
    }
    _componentsManager.callComponentDestroy();
}

void Engine::_render(ScenePtr scene, float deltaTime) {
    const auto& cameras = scene->_activeCameras;
    _componentsManager.callRendererOnUpdate(deltaTime);
    
    scene->_updateShaderData();
    
    if (cameras.size() > 0) {
        for (size_t i = 0, l = cameras.size(); i < l; i++) {
            const auto& camera = cameras[i];
            const auto& cameraEntity = camera->entity();
            if (camera->enabled() && cameraEntity->isActiveInHierarchy()) {
                _componentsManager.callCameraOnBeginRender(camera);
                camera->render();
                _componentsManager.callCameraOnEndRender(camera);
            }
        }
    } else {
        log::Err() << "NO active camera." << std::endl;
    }
}

}
