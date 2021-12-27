//
//  modelio_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/27.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/gpu_skinned_mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/animator.h"
#include "../vox.render/runtime/scene_animator.h"
#include "../vox.render/runtime/material/unlit_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/controls/free_control.h"
#include "../vox.render/runtime/lighting/point_light.h"
#include "../vox.render/runtime/lighting/direct_light.h"
#include "../vox.render/offline/modelio_loader.h"

using namespace vox;

class SkyMove: public Script {
public:
    SkyMove(Entity* entity):Script(entity) {}
    
    void onUpdate(float deltaTime) override {
        skyRotation += 0.5f;
        entity()->transform->setRotation(0, skyRotation, 0);
    }
    
private:
    float skyRotation = -135;
};

class SunMove: public Script {
public:
    SunMove(Entity* entity):Script(entity) {
        entity->transform->setPosition(0.25, 0.5, -1.0);
    }
    
    void onUpdate(float deltaTime) override {
        entity()->transform->lookAt(Float3());
    }
};

int main(int, char**) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    scene->ambientLight().setDiffuseSolidColor(math::Color(0.1,0.1,0.1));

    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(-6.02535057, 36.6681671, 48.6991844);
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    auto sky = rootEntity->createChild("sky");
    sky->addComponent<SkyMove>();
    auto sun = sky->createChild("sun");
    sun->addComponent<SunMove>();
    auto diretLight = sun->addComponent<DirectLight>();
    diretLight->shadow.intensity = 0;
    diretLight->intensity = 1.0;
    diretLight->setEnableShadow(true);
    
    auto loader = offline::ModelIOLoader(&engine);
    loader.loadFromFile("../models/Temple", "Temple.obj");
    loader.defaultSceneRoot->transform->setScale(0.05, 0.05, 0.05);
    loader.defaultSceneRoot->transform->setPosition(0, -10, 0);
    for (auto& renderer : loader.renderers) {
        renderer->castShadow = true;
        renderer->receiveShadow = true;
    }
    rootEntity->addChild(loader.defaultSceneRoot);
    
    engine.run();
}
