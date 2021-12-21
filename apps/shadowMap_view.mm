//
//  shadowMap_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/21.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/material/unlit_material.h"
#include "../vox.render/runtime/material/blinn_phong_material.h"
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
    pointLight->setEnableShadow(true);
    
    // create box test entity
    float cubeSize = 2.0;
    auto boxEntity = rootEntity->createChild("BoxEntity");
    boxEntity->transform->setPosition(Float3(0, 2, 0));
    auto boxMtl = std::make_shared<BlinnPhongMaterial>(&engine);
    boxMtl->setBaseColor(math::Color(0.3, 0.3, 0.3, 0.5));
    
    auto boxRenderer = boxEntity->addComponent<MeshRenderer>();
    boxRenderer->setMesh(PrimitiveMesh::createCuboid(&engine, cubeSize, cubeSize, cubeSize));
    boxRenderer->setMaterial(boxMtl);
    boxRenderer->castShadow = true;
    
    auto planeEntity = rootEntity->createChild("PlaneEntity");
    auto planeMtl = std::make_shared<BlinnPhongMaterial>(&engine);
    planeMtl->setBaseColor(math::Color(1.0, 0, 0, 1.0));
    planeMtl->setRenderFace(RenderFace::Enum::Double);
    
    auto planeRenderer = planeEntity->addComponent<MeshRenderer>();
    planeRenderer->setMesh(PrimitiveMesh::createPlane(&engine, 10, 10));
    planeRenderer->setMaterial(planeMtl);

    engine.run();
}
