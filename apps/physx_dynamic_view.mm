//
//  physx_dynamic_view.m
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
#include "../vox.render/runtime/physics/dynamic_collider.h"
#include "../vox.render/runtime/physics/shape/box_collider_shape.h"
#include "../vox.render/runtime/physics/shape/sphere_collider_shape.h"
#include "../vox.render/runtime/physics/shape/plane_collider_shape.h"
#include "../vox.render/runtime/physics/shape/capsule_collider_shape.h"
#include <random>

using namespace vox;

int main(int, char**) {
    std::default_random_engine e;
    std::uniform_real_distribution<float> u(0, 1);
    
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
    
    auto addPlane = [&](const math::Float3& size, const math::Float3& position, const math::Quaternion& rotation) {
        auto mtl = std::make_shared<UnlitMaterial>(&engine);
        mtl->setBaseColor(math::Color(0.03179807202597362, 0.3939682161541871, 0.41177952549087604, 1.0));
        auto planeEntity = rootEntity->createChild();
        planeEntity->layer = Layer::Layer1;

        auto renderer = planeEntity->addComponent<MeshRenderer>();
        renderer->setMesh(PrimitiveMesh::createCuboid(&engine, size.x, size.y, size.z));
        renderer->setMaterial(mtl);
        planeEntity->transform->setPosition(position);
        planeEntity->transform->setRotationQuaternion(rotation);

        auto physicsPlane = std::make_shared<physics::PlaneColliderShape>();
        auto planeCollider = planeEntity->addComponent<physics::StaticCollider>();
        planeCollider->addShape(physicsPlane);

        return planeEntity;
    };
    
    auto addBox = [&](const math::Float3& size, const math::Float3& position, const math::Quaternion& rotation) {
        auto boxMtl = std::make_shared<UnlitMaterial>(&engine);
        boxMtl->setBaseColor(math::Color(0.8, 0.3, 0.3, 1.0));
        auto boxEntity = rootEntity->createChild("BoxEntity");
        auto boxRenderer = boxEntity->addComponent<MeshRenderer>();
        
        boxRenderer->setMesh(PrimitiveMesh::createCuboid(&engine, size.x, size.y, size.z));
        boxRenderer->setMaterial(boxMtl);
        boxEntity->transform->setPosition(position);
        boxEntity->transform->setRotationQuaternion(rotation);
        
        auto boxColliderShape = std::make_shared<physics::BoxColliderShape>();
        boxColliderShape->setSize(math::Float3(size.x, size.y, size.z));
        
        auto boxCollider = boxEntity->addComponent<physics::DynamicCollider>();
        boxCollider->addShape(boxColliderShape);
        
        return boxEntity;
    };
    
    addPlane(math::Float3(30, 0.1, 30), math::Float3(), math::Quaternion());
    for(int i = 0; i < 5; i++) {
        for(int j = 0; j < 5; j++) {
            addBox(math::Float3(1, 1, 1),
                   math::Float3(-2.5 + i + 0.1 * i, u(e) * 6.f + 1, -2.5 + j + 0.1 * j),
                   Quaternion(0, 0, 0.3, 0.7));
        }
    }

    
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
};
