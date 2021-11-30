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
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/material/unlit_material.h"

using namespace vox;

int main(int, char**) {
    auto canvas = Canvas(1280, 720, "vox.render");
    auto engine = Engine(canvas);
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(10, 10, 10);
    cameraEntity->transform->lookAt(Float3(0, 0, 0));
    cameraEntity->addComponent<vox::Camera>();
    
    auto boxEntity = rootEntity->createChild("BoxEntity");
    auto boxRenderer = boxEntity->addComponent<MeshRenderer>();
    boxRenderer->setMesh(PrimitiveMesh::createCuboid(&engine, 2, 2, 2));
    auto boxMtl = std::make_shared<UnlitMaterial>(&engine);
    boxMtl->setBaseColor(math::Color(0.6, 0.3, 0.4, 1));
    boxRenderer->setMaterial(boxMtl);
    
    engine.run();
}
