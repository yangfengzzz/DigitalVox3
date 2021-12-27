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
#include "../vox.render/runtime/mesh/skinned_mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/animator.h"
#include "../vox.render/runtime/scene_animator.h"
#include "../vox.render/runtime/material/unlit_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/controls/free_control.h"
#include "../vox.render/runtime/lighting/point_light.h"
#include "../vox.render/offline/modelio_loader.h"

using namespace vox;

int main(int, char**) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(5, 5, 1);
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::FreeControl>();
    
    // init point light
    auto light = rootEntity->createChild("light");
    light->transform->setPosition(5.0f, 5.0f, -5.0f);
    light->addComponent<PointLight>();
    
    auto loader = offline::ModelIOLoader(&engine);
    loader.loadFromFile("../models/Temple", "Temple.obj");
    rootEntity->addChild(loader.defaultSceneRoot);
    
    engine.run();
}
