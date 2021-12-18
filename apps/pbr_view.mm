//
//  pbr_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/18.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/material/pbr_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/lighting/point_light.h"
#include <random>

using namespace vox;

int main(int, char**) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    scene->ambientLight().setDiffuseSolidColor(math::Color(1,1,1));
    
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
    
    auto sphere = PrimitiveMesh::createSphere(&engine);
    for (int i = 0; i < 7; i++) {
        for (int j = 0; j < 7; j++) {
            auto sphereEntity = rootEntity->createChild("SphereEntity" + std::to_string(i) + std::to_string(j));
            sphereEntity->transform->setPosition(math::Float3(i-3, j-3, 0));
            auto sphereMtl = std::make_shared<PBRMaterial>(&engine);
            auto sphereRenderer = sphereEntity->addComponent<MeshRenderer>();
            sphereRenderer->setMesh(sphere);
            sphereRenderer->setMaterial(sphereMtl);
        }
    }
    
    engine.run();
}
