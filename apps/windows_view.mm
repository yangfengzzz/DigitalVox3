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
#include "../vox.render/runtime/controls/orbit_control.h"

using namespace vox;

int main(int, char**) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto resourceLoader = engine.resourceLoader();
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(1, 1, 1);
    cameraEntity->transform->lookAt(Float3(0, 0, 0));
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    auto boxMtl = std::make_shared<UnlitMaterial>(&engine);
    boxMtl->setBaseTexture(resourceLoader->loadTexture("../models/Doggy", "T_Doggy_1_diffuse.png", false));
    
    auto characterEntity = rootEntity->createChild("characterEntity");
    auto characterRenderer = characterEntity->addComponent<SkinnedMeshRenderer>();
    characterRenderer->addSkinnedMesh("../models/Doggy/Doggy.fbx",
                                      "../models/Doggy/doggy_skeleton.ozz");
    characterRenderer->setMaterial(boxMtl);
    auto characterAnim = characterEntity->addComponent<Animator>();
    characterAnim->addAnimationClip("../models/Doggy/Run.ozz");
    
    engine.run();
}
