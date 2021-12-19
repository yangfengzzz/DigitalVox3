//
//  Irradiance_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/18.
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
#include "../vox.render/runtime/material/pbr_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/lighting/point_light.h"
#include "../vox.render/runtime/sky/skybox_material.h"

#include "../vox.render/offline/gltf_loader.h"

using namespace vox;

int main(int, char**) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto resourceLoader = engine.resourceLoader();
    auto scene = engine.sceneManager().activeScene();
    auto rootEntity = scene->createRootEntity();
    
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(0, 0, 10);
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    // Create Sphere
    auto sphereEntity = rootEntity->createChild("box");
    sphereEntity->transform->setPosition(-1, 2, 0);
    auto sphereMaterial = std::make_shared<PBRMaterial>(&engine);
    sphereMaterial->setRoughness(0);
    sphereMaterial->setMetallic(1);
    auto renderer = sphereEntity->addComponent<MeshRenderer>();
    renderer->setMesh(PrimitiveMesh::createSphere(&engine, 1, 64));
    renderer->setMaterial(sphereMaterial);
    
    // Create planes
    std::array<EntityPtr, 6> planes{};
    std::array<MaterialPtr, 6> planeMaterials{};
    
    for (int i = 0; i < 6; i++) {
        auto bakerEntity = rootEntity->createChild("IBL Baker Entity");
        bakerEntity->transform->setRotation(90, 0, 0);
        auto bakerMaterial = std::make_shared<UnlitMaterial>(&engine);
        bakerMaterial->renderState.rasterState.cullMode = MTLCullModeNone;
        auto bakerRenderer = bakerEntity->addComponent<MeshRenderer>();
        bakerRenderer->setMesh(PrimitiveMesh::createPlane(&engine, 2, 2));
        bakerRenderer->setMaterial(bakerMaterial);
        planes[i] = bakerEntity;
        planeMaterials[i] = bakerMaterial;
    }
    
    planes[0]->transform->setPosition(1, 0, 0); // PX
    planes[1]->transform->setPosition(-3, 0, 0); // NX
    planes[2]->transform->setPosition(1, 2, 0); // PY
    planes[3]->transform->setPosition(1, -2, 0); // NY
    planes[4]->transform->setPosition(-1, 0, 0); // PZ
    planes[5]->transform->setPosition(3, 0, 0); // NZ
    
    
    auto textures = resourceLoader->createIrradianceTexture
                                   ("/Users/yangfeng/Desktop/met-materials/12-environment/projects/resources/IrradianceGenerator/IrradianceGenerator/Sky Images",
                                    {"posx.png", "negx.png", "posy.png", "negy.png", "posz.png", "negz.png"});

    
    engine.run();
}
