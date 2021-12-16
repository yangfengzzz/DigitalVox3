//
//  gltf_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/16.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/skinned_mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/animator.h"
#include "../vox.render/runtime/material/unlit_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/lighting/point_light.h"
#include "../vox.render/offline/gltf_loader.h"

using namespace vox;

int main(int, char**) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(10, 10, 10);
    cameraEntity->transform->lookAt(Float3(0, 0, 0));
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    // init point light
    auto light = rootEntity->createChild("light");
    light->transform->setPosition(0, 3, 0);
    auto pointLight = light->addComponent<PointLight>();
    pointLight->intensity = 0.3;
    
    auto loader = offline::GLTFLoader(&engine);
    loader.loadFromFile("../models/FlightHelmet/glTF/FlightHelmet.gltf");
    
    engine.run();
}
