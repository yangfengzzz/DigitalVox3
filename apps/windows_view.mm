//
//  windows_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/11/29.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/skinned_mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/animator.h"
#include "../vox.render/runtime/material/unlit_material.h"
#include "../vox.render/runtime/material/blinn_phong_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/lighting/direct_light.h"

using namespace vox;

class lightMovemenet: public Script {
public:
    const float speed = 1;
    float totalTime = 0;
    
    lightMovemenet(Entity* entity):Script(entity) {}
    
    void onUpdate(float deltaTime) override {
        totalTime += deltaTime;
        totalTime = fmod(totalTime, 100);
        entity()->transform->setPosition(10*std::sin(speed * totalTime), 10, 10*std::cos(speed * totalTime));
        entity()->transform->lookAt(Float3(0, 0, 0));
    }
};

int main(int, char**) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto resourceLoader = engine.resourceLoader();
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
    light->transform->setPosition(0, 10, 0);
    light->transform->lookAt(Float3(0, 0, 0), Float3(1, 0, 0));
    light->addComponent<lightMovemenet>();
    auto directionLight = light->addComponent<DirectLight>();
    directionLight->intensity = 1.0;
    directionLight->setEnableShadow(true);
    
    auto characterMtl = std::make_shared<UnlitMaterial>(&engine);
    characterMtl->setBaseTexture(resourceLoader->loadTexture("../models/Doggy", "T_Doggy_1_diffuse.png", false));
    
    auto characterEntity = rootEntity->createChild("characterEntity");
    characterEntity->transform->setScale(3, 3, 3);
    auto characterRenderer = characterEntity->addComponent<SkinnedMeshRenderer>();
    characterRenderer->castShadow = true;
    characterRenderer->addSkinnedMesh("../models/Doggy/Doggy.fbx",
                                      "../models/Doggy/doggy_skeleton.ozz");
    characterRenderer->setMaterial(characterMtl);
    auto characterAnim = characterEntity->addComponent<Animator>();
    characterAnim->addAnimationClip("../models/Doggy/Run.ozz");
    
    auto planeEntity = rootEntity->createChild("PlaneEntity");
    auto planeMtl = std::make_shared<BlinnPhongMaterial>(&engine);
    planeMtl->setBaseColor(math::Color(1.0, 0, 0, 1.0));
    planeMtl->setRenderFace(RenderFace::Enum::Double);
    
    auto planeRenderer = planeEntity->addComponent<MeshRenderer>();
    planeRenderer->setMesh(PrimitiveMesh::createPlane(&engine, 10, 10));
    planeRenderer->setMaterial(planeMtl);
    planeRenderer->castShadow = true;
    planeRenderer->receiveShadow = true;
    
    engine.run();
}
