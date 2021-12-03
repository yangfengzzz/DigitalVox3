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
#include "../vox.render/runtime/physics/dynamic_collider.h"
#include "../vox.render/runtime/physics/shape/box_collider_shape.h"
#include "../vox.render/runtime/physics/shape/sphere_collider_shape.h"
#include <random>

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
    
    // create sphere test entity
    float radius = 1.25;
    auto sphereEntity = rootEntity->createChild("SphereEntity");
    sphereEntity->transform->setPosition(math::Float3(-5, 0, 0));
    auto sphereRenderer = sphereEntity->addComponent<MeshRenderer>();
    auto sphereMtl = std::make_shared<UnlitMaterial>(&engine);
    std::default_random_engine e;
    std::uniform_real_distribution<float> u(0, 1);
    sphereMtl->setBaseColor(math::Color(u(e), u(e), u(e), 1));
    sphereRenderer->setMesh(PrimitiveMesh::createSphere(&engine, radius));
    sphereRenderer->setMaterial(sphereMtl);

    auto sphereCollider = sphereEntity->addComponent<physics::DynamicCollider>();
    auto sphereColliderShape = std::make_shared<physics::SphereColliderShape>();
    sphereColliderShape->setRadius(radius);
    sphereColliderShape->setTrigger(true);
    sphereCollider->addShape(sphereColliderShape);
    
    class MoveScript:public Script {
        math::Float3 pos = math::Float3(-5, 0, 0);
        float vel = 4;
        int8_t velSign = -1;
        
    public:
        MoveScript(Entity* entity):Script(entity) {}
        
        void onUpdate(float deltaTime) override {
            if (pos.x >= 5) {
                velSign = -1;
            }
            if (pos.x <= -5) {
                velSign = 1;
            }
            pos.x += deltaTime * vel * float(velSign);

            entity()->transform->setPosition(pos);
        }
    };
    
    // Collision Detection
    class CollisionScript: public Script {
        MeshRenderer* sphereRenderer;
        std::default_random_engine e;
        std::uniform_real_distribution<float> u;
        
    public:
        CollisionScript(Entity* entity):Script(entity) {
            sphereRenderer = entity->getComponent<MeshRenderer>();
            u = std::uniform_real_distribution<float>(0, 1);
        }

        void onTriggerExit(physics::ColliderShapePtr other) override {
            static_cast<UnlitMaterial*>(sphereRenderer->getMaterial().get())->setBaseColor(math::Color(u(e), u(e), u(e), 1));
        }

        void onTriggerEnter(physics::ColliderShapePtr other) override {
            static_cast<UnlitMaterial*>(sphereRenderer->getMaterial().get())->setBaseColor(math::Color(u(e), u(e), u(e), 1));
        }
    };
    
    sphereEntity->addComponent<CollisionScript>();
    sphereEntity->addComponent<MoveScript>();
    
    engine.run();
}
