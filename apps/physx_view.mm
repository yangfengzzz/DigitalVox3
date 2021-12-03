//
//  physx_view.m
//  apps
//
//  Created by 杨丰 on 2021/12/4.
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
#include "../vox.render/runtime/physics/static_collider.h"
#include "../vox.render/runtime/physics/shape/box_collider_shape.h"

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
    cameraEntity->addComponent<control::OrbitControl>();
    
    // create box test entity
    float cubeSize = 2.0;
    auto boxEntity = rootEntity->createChild("BoxEntity");
    auto boxMtl = std::make_shared<UnlitMaterial>(&engine);
    auto boxRenderer = boxEntity->addComponent<MeshRenderer>();
    boxMtl->setBaseColor(math::Color(0.8, 0.3, 0.3, 1.0));
    boxRenderer->setMesh(PrimitiveMesh::createCuboid(&engine, cubeSize, cubeSize, cubeSize));
    boxRenderer->setMaterial(boxMtl);

    auto boxCollider = boxEntity->addComponent<physics::StaticCollider>();
    auto boxColliderShape = std::make_shared<physics::BoxColliderShape>();
    boxColliderShape->setSize(math::Float3(cubeSize, cubeSize, cubeSize));
    boxCollider->addShape(boxColliderShape);
    
    engine.run();
}
