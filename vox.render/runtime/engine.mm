//
//  engine.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "engine.h"
#include "camera.h"
#include "log.h"
#include "material/material.h"
#include "shader/shader_pool.h"

namespace vox {
Engine::Engine(Canvas* canvas):_canvas(canvas), _hardwareRenderer(canvas) {
    ShaderPool::initialization();
    
    _sceneManager.setActiveScene(std::make_shared<Scene>(this, "DefaultScene"));
    const uint8_t whitePixel[] = {255, 255, 255, 255};
    
    MTLTextureDescriptor* whiteTextureDescriptor = [[MTLTextureDescriptor alloc]init];
    whiteTextureDescriptor.width = 1;
    whiteTextureDescriptor.height = 1;
    whiteTextureDescriptor.pixelFormat = MTLPixelFormatRGBA8Uint;
    whiteTextureDescriptor.textureType = MTLTextureType2D;
    _whiteTexture2D = [_hardwareRenderer.device newTextureWithDescriptor:whiteTextureDescriptor];
    [_whiteTexture2D replaceRegion:MTLRegionMake2D(0, 0, 1, 1)
                       mipmapLevel:0 withBytes:&whitePixel
                       bytesPerRow: 4 * sizeof(uint8_t)];
    
    MTLTextureDescriptor* whiteTextureCubeDescriptor =[[MTLTextureDescriptor alloc]init];
    whiteTextureCubeDescriptor.width = 1;
    whiteTextureCubeDescriptor.height = 1;
    whiteTextureCubeDescriptor.pixelFormat = MTLPixelFormatRGBA8Uint;
    whiteTextureCubeDescriptor.textureType = MTLTextureTypeCube;
    _whiteTextureCube = [_hardwareRenderer.device newTextureWithDescriptor:whiteTextureCubeDescriptor];
    [_whiteTextureCube replaceRegion:MTLRegionMake2D(0, 0, 1, 1)
                         mipmapLevel:0 slice:0
                           withBytes:&whitePixel
                         bytesPerRow:4 * sizeof(uint8_t)
                       bytesPerImage:4 * sizeof(uint8_t)];
    [_whiteTextureCube replaceRegion:MTLRegionMake2D(0, 0, 1, 1)
                         mipmapLevel:0 slice:1
                           withBytes:&whitePixel
                         bytesPerRow:4 * sizeof(uint8_t)
                       bytesPerImage:4 * sizeof(uint8_t)];
    [_whiteTextureCube replaceRegion:MTLRegionMake2D(0, 0, 1, 1)
                         mipmapLevel:0 slice:2
                           withBytes:&whitePixel
                         bytesPerRow:4 * sizeof(uint8_t)
                       bytesPerImage:4 * sizeof(uint8_t)];
    [_whiteTextureCube replaceRegion:MTLRegionMake2D(0, 0, 1, 1)
                         mipmapLevel:0 slice:3
                           withBytes:&whitePixel
                         bytesPerRow:4 * sizeof(uint8_t)
                       bytesPerImage:4 * sizeof(uint8_t)];
    [_whiteTextureCube replaceRegion:MTLRegionMake2D(0, 0, 1, 1)
                         mipmapLevel:0 slice:4
                           withBytes:&whitePixel
                         bytesPerRow:4 * sizeof(uint8_t)
                       bytesPerImage:4 * sizeof(uint8_t)];
    [_whiteTextureCube replaceRegion:MTLRegionMake2D(0, 0, 1, 1)
                         mipmapLevel:0 slice:5
                           withBytes:&whitePixel
                         bytesPerRow:4 * sizeof(uint8_t)
                       bytesPerImage:4 * sizeof(uint8_t)];
    
    _backgroundTextureMaterial = std::make_shared<Material>(this, Shader::find("background-texture"));
    _backgroundTextureMaterial->renderState.depthState.compareFunction = MTLCompareFunctionLessEqual;
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
        _componentsManager.callScriptOnUpdate(deltaTime);
        _componentsManager.callAnimatorUpdate(deltaTime);
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
