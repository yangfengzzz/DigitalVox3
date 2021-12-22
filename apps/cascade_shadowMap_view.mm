//
//  cascade_shadowMap_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/22.
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
    
    Shader::create("shadowMapDebugger", "vertex_shadow_debugger", "fragment_shadow_debugger");
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(0, 10, 50);
    cameraEntity->transform->lookAt(Float3(0, 0, 0));
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    auto light = rootEntity->createChild("light");
    light->transform->setPosition(10, 10, 0);
    light->transform->lookAt(Float3());
    auto directLight = light->addComponent<DirectLight>();
    directLight->intensity = 1.0;
    directLight->setEnableShadow(true);

    // create box test entity
    float cubeSize = 2.0;
    auto boxMesh = PrimitiveMesh::createCuboid(&engine, cubeSize, cubeSize, cubeSize);
    auto boxMtl = std::make_shared<BlinnPhongMaterial>(&engine);
    boxMtl->setBaseColor(math::Color(0.3, 0.3, 0.3, 0.5));
    for (int i = 0; i < 4; i++) {
        auto boxEntity = rootEntity->createChild("BoxEntity");
        boxEntity->transform->setPosition(Float3(0, 2, i * 10 - 10));

        auto boxRenderer = boxEntity->addComponent<MeshRenderer>();
        boxRenderer->setMesh(boxMesh);
        boxRenderer->setMaterial(boxMtl);
        boxRenderer->castShadow = true;
    }
    
    auto planeEntity = rootEntity->createChild("PlaneEntity");
    auto planeMtl = std::make_shared<BlinnPhongMaterial>(&engine);
    planeMtl->setBaseColor(math::Color(1.0, 0, 0, 1.0));
    planeMtl->setRenderFace(RenderFace::Enum::Double);
    
    auto planeRenderer = planeEntity->addComponent<MeshRenderer>();
    planeRenderer->setMesh(PrimitiveMesh::createPlane(&engine, 10, 50));
    planeRenderer->setMaterial(planeMtl);
    planeRenderer->receiveShadow = true;
    
    // shadow view
//    auto shadowViewEntity = rootEntity->createChild("ShadowDebugEntity");
//    shadowViewEntity->transform->setPosition(Float3(6, 0, 0));
//    auto shadowMtl = std::make_shared<ShadowDebugMaterial>(&engine);
//    shadowMtl->setRenderFace(RenderFace::Enum::Double);
//
//    auto shadowViewRenderer = shadowViewEntity->addComponent<MeshRenderer>();
//    shadowViewRenderer->setMesh(PrimitiveMesh::createPlane(&engine, 2, 2));
//    shadowViewRenderer->setMaterial(shadowMtl);

    engine.run();
}
