//
//  omni_shadowMap_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/24.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/material/unlit_material.h"
#include "../vox.render/runtime/material/blinn_phong_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/lighting/direct_light.h"
#include "../vox.render/runtime/lighting/spot_light.h"
#include "../vox.render/runtime/lighting/point_light.h"
#include <random>

using namespace vox;

class ShadowDebugMaterial :public BaseMaterial {
public:
    ShadowDebugMaterial(Engine* engine):BaseMaterial(engine, Shader::find("shadowMapDebugger")){}
};

int main(int, char**) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    
    Shader::create("shadowMapDebugger", "vertex_shadow_debugger", "fragment_cascade_shadow_debugger");
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(0, 0, 20);
    cameraEntity->transform->lookAt(Float3(0, 0, 0));
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    auto light = rootEntity->createChild("light");
    light->transform->setPosition(0, 0, 0);
    auto directLight = light->addComponent<PointLight>();
    directLight->intensity = 1.0;
    directLight->setEnableShadow(true);
    
    auto planeMesh = PrimitiveMesh::createPlane(&engine, 10, 10);
    
    auto planeEntity = rootEntity->createChild("PlaneEntity");
    planeEntity->transform->setPosition(0, 5, 0);
    auto planeMtl = std::make_shared<BlinnPhongMaterial>(&engine);
    planeMtl->setBaseColor(math::Color(0.2, 0.2, 0.2, 1.0));
    planeMtl->setRenderFace(RenderFace::Enum::Double);
    auto planeRenderer = planeEntity->addComponent<MeshRenderer>();
    planeRenderer->setMesh(planeMesh);
    planeRenderer->setMaterial(planeMtl);
    planeRenderer->receiveShadow = true;
    
    auto planeEntity2 = rootEntity->createChild("PlaneEntity2");
    planeEntity2->transform->setPosition(0, -5, 0);
    auto planeMtl2 = std::make_shared<BlinnPhongMaterial>(&engine);
    planeMtl2->setBaseColor(math::Color(0.4, 0.4, 0.4, 1.0));
    planeMtl2->setRenderFace(RenderFace::Enum::Double);
    auto planeRenderer2 = planeEntity2->addComponent<MeshRenderer>();
    planeRenderer2->setMesh(planeMesh);
    planeRenderer2->setMaterial(planeMtl2);
    planeRenderer2->receiveShadow = true;
    
    auto planeEntity3 = rootEntity->createChild("PlaneEntity3");
    planeEntity3->transform->setPosition(5, 0, 0);
    planeEntity3->transform->setRotation(90, 0, 0);
    auto planeMtl3 = std::make_shared<BlinnPhongMaterial>(&engine);
    planeMtl3->setBaseColor(math::Color(0.6, 0.6, 0.6, 1.0));
    planeMtl3->setRenderFace(RenderFace::Enum::Double);
    auto planeRenderer3 = planeEntity3->addComponent<MeshRenderer>();
    planeRenderer3->setMesh(planeMesh);
    planeRenderer3->setMaterial(planeMtl3);
    planeRenderer3->receiveShadow = true;
    
    auto planeEntity4 = rootEntity->createChild("PlaneEntity4");
    planeEntity4->transform->setPosition(-5, 0, 0);
    planeEntity4->transform->setRotation(-90, 0, 0);
    auto planeMtl4 = std::make_shared<BlinnPhongMaterial>(&engine);
    planeMtl4->setBaseColor(math::Color(0.8, 0.8, 0.8, 1.0));
    planeMtl4->setRenderFace(RenderFace::Enum::Double);
    auto planeRenderer4 = planeEntity4->addComponent<MeshRenderer>();
    planeRenderer4->setMesh(planeMesh);
    planeRenderer4->setMaterial(planeMtl4);
    planeRenderer4->receiveShadow = true;
    
    auto planeEntity5 = rootEntity->createChild("PlaneEntity5");
    planeEntity5->transform->setPosition(0, 0, -5);
    planeEntity5->transform->setRotation(0, 0, 90);
    auto planeMtl5 = std::make_shared<BlinnPhongMaterial>(&engine);
    planeMtl5->setBaseColor(math::Color(1.0, 1.0, 1.0, 1.0));
    planeMtl5->setRenderFace(RenderFace::Enum::Double);
    auto planeRenderer5 = planeEntity5->addComponent<MeshRenderer>();
    planeRenderer5->setMesh(planeMesh);
    planeRenderer5->setMaterial(planeMtl5);
    planeRenderer5->receiveShadow = true;
    
    // create box test entity
    float cubeSize = 1.0;
    auto boxMesh = PrimitiveMesh::createCuboid(&engine, cubeSize, cubeSize, cubeSize);
    auto boxMtl = std::make_shared<BlinnPhongMaterial>(&engine);
    boxMtl->setBaseColor(math::Color(1.0, 0.0, 0.0, 0.5));
    boxMtl->setRenderFace(RenderFace::Enum::Double); // bug
    auto boxEntity = rootEntity->createChild("BoxEntity");
    boxEntity->transform->setPosition(0, 0, -3);
    auto boxRenderer = boxEntity->addComponent<MeshRenderer>();
    boxRenderer->setMesh(boxMesh);
    boxRenderer->setMaterial(boxMtl);
    boxRenderer->castShadow = true;
    
    engine.run();
}

