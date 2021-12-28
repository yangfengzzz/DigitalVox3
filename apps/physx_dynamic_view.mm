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
#include "../vox.render/runtime/material/blinn_phong_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/physics/static_collider.h"
#include "../vox.render/runtime/physics/dynamic_collider.h"
#include "../vox.render/runtime/physics/character_controller/capsule_character_controller.h"
#include "../vox.render/runtime/physics/joint/fixed_joint.h"
#include "../vox.render/runtime/physics/shape/box_collider_shape.h"
#include "../vox.render/runtime/physics/shape/sphere_collider_shape.h"
#include "../vox.render/runtime/physics/shape/plane_collider_shape.h"
#include "../vox.render/runtime/physics/shape/capsule_collider_shape.h"
#include "../vox.render/runtime/lighting/direct_light.h"
#include <random>

using namespace vox;

class ControllerScript : public Script {
public:
    physics::CharacterController *character;
    math::Float3 displacement;
    
    ControllerScript(Entity *entity) : Script(entity) {
        character = entity->getComponent<physics::CharacterController>();
    }
    
    void onUpdate(float deltaTime) override {
        auto flags = character->move(displacement, 0.1, deltaTime);
        displacement.x = 0;
        displacement.y = 0;
        displacement.z = 0;
        if (!flags.isSet(physx::PxControllerCollisionFlag::Enum::eCOLLISION_DOWN)) {
            character->move(math::Float3(0, -0.2, 0), 0.1, deltaTime);
        }
    }
};

int main(int, char **) {
    std::default_random_engine e;
    std::uniform_real_distribution<float> u(0, 1);
    
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(20, 20, 20);
    cameraEntity->transform->lookAt(Float3(0, 0, 0));
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    auto addPlane = [&](const math::Float3 &size, const math::Float3 &position, const math::Quaternion &rotation) {
        auto mtl = std::make_shared<BlinnPhongMaterial>(&engine);
        mtl->setBaseColor(math::Color(0.03179807202597362, 0.3939682161541871, 0.41177952549087604, 1.0));
        auto planeEntity = rootEntity->createChild();
        planeEntity->layer = Layer::Layer1;
        
        auto renderer = planeEntity->addComponent<MeshRenderer>();
        renderer->receiveShadow = true;
        renderer->setMesh(PrimitiveMesh::createCuboid(&engine, size.x, size.y, size.z));
        renderer->setMaterial(mtl);
        planeEntity->transform->setPosition(position);
        planeEntity->transform->setRotationQuaternion(rotation);
        
        auto physicsPlane = std::make_shared<physics::PlaneColliderShape>();
        auto planeCollider = planeEntity->addComponent<physics::StaticCollider>();
        planeCollider->addShape(physicsPlane);
        
        return planeEntity;
    };
    
    auto addBox = [&](const math::Float3 &size, const math::Float3 &position, const math::Quaternion &rotation) {
        auto boxMtl = std::make_shared<BlinnPhongMaterial>(&engine);
        boxMtl->setBaseColor(math::Color(u(e), u(e), u(e), 1.0));
        auto boxEntity = rootEntity->createChild("BoxEntity");
        auto boxRenderer = boxEntity->addComponent<MeshRenderer>();
        boxRenderer->castShadow = true;
        boxRenderer->setMesh(PrimitiveMesh::createCuboid(&engine, size.x, size.y, size.z));
        boxRenderer->setMaterial(boxMtl);
        boxEntity->transform->setPosition(position);
        boxEntity->transform->setRotationQuaternion(rotation);
        
        auto physicsBox = std::make_shared<physics::BoxColliderShape>();
        physicsBox->setSize(math::Float3(size.x, size.y, size.z));
        physicsBox->material()->setStaticFriction(1);
        physicsBox->material()->setDynamicFriction(2);
        physicsBox->material()->setRestitution(0.1);
        physicsBox->setTrigger(false);
        
        auto boxCollider = boxEntity->addComponent<physics::DynamicCollider>();
        boxCollider->addShape(physicsBox);
        
        return boxEntity;
    };
    
    auto addSphere = [&](float radius, const math::Float3 &position, const math::Quaternion &rotation, const math::Float3 &velocity) {
        auto mtl = std::make_shared<BlinnPhongMaterial>(&engine);
        mtl->setBaseColor(math::Color(u(e), u(e), u(e), 1.0));
        auto sphereEntity = rootEntity->createChild();
        auto renderer = sphereEntity->addComponent<MeshRenderer>();
        renderer->castShadow = true;
        renderer->setMesh(PrimitiveMesh::createSphere(&engine, radius));
        renderer->setMaterial(mtl);
        sphereEntity->transform->setPosition(position);
        sphereEntity->transform->setRotationQuaternion(rotation);
        
        auto physicsSphere = std::make_shared<physics::SphereColliderShape>();
        physicsSphere->setRadius(radius);
        physicsSphere->material()->setStaticFriction(0.1);
        physicsSphere->material()->setDynamicFriction(0.2);
        physicsSphere->material()->setRestitution(1);
        physicsSphere->material()->setRestitutionCombineMode(physx::PxCombineMode::Enum::eMIN);
        
        auto sphereCollider = sphereEntity->addComponent<physics::DynamicCollider>();
        sphereCollider->addShape(physicsSphere);
        sphereCollider->setLinearVelocity(velocity);
        sphereCollider->setAngularDamping(0.5);
        
        return sphereEntity;
    };
    
    auto addCapsule = [&](float radius, float height, const math::Float3 &position, const math::Quaternion &rotation) {
        auto mtl = std::make_shared<BlinnPhongMaterial>(&engine);
        mtl->setBaseColor(math::Color(u(e), u(e), u(e), 1.0));
        auto capsuleEntity = rootEntity->createChild();
        auto renderer = capsuleEntity->addComponent<MeshRenderer>();
        renderer->castShadow = true;
        renderer->setMesh(PrimitiveMesh::createCapsule(&engine, radius, height));
        renderer->setMaterial(mtl);
        capsuleEntity->transform->setPosition(position);
        capsuleEntity->transform->setRotationQuaternion(rotation);
        
        auto physicsCapsule = std::make_shared<physics::CapsuleColliderShape>();
        physicsCapsule->setRadius(radius);
        physicsCapsule->setHeight(height);
        
        auto capsuleCollider = capsuleEntity->addComponent<physics::DynamicCollider>();
        capsuleCollider->addShape(physicsCapsule);
        
        return capsuleEntity;
    };
    
    auto addPlayer = [&](float radius, float height, const math::Float3 &position, const math::Quaternion &rotation) {
        auto mtl = std::make_shared<BlinnPhongMaterial>(&engine);
        mtl->setBaseColor(math::Color(u(e), u(e), u(e), 1.0));
        auto capsuleEntity = rootEntity->createChild();
        auto renderer = capsuleEntity->addComponent<MeshRenderer>();
        renderer->castShadow = true;
        renderer->setMesh(PrimitiveMesh::createCapsule(&engine, radius, height, 20));
        renderer->setMaterial(mtl);
        capsuleEntity->transform->setPosition(position);
        capsuleEntity->transform->setRotationQuaternion(rotation);
        
        auto characterController = capsuleEntity->addComponent<physics::CapsuleCharacterController>();
        physx::PxCapsuleControllerDesc characterControllerDesc;
        characterControllerDesc.radius = radius;
        characterControllerDesc.height = height;
        characterControllerDesc.material = physics::PhysicsManager::_nativePhysics()->createMaterial(0,0,0);
        auto worldPos = capsuleEntity->transform->worldPosition();
        characterControllerDesc.position = physx::PxExtendedVec3(worldPos.x, worldPos.y, worldPos.z);
        characterController->setDesc(characterControllerDesc);
        
        return capsuleEntity;
    };
    
    class ControllerScript: public Script {
    public:
        ControllerScript(Entity* entity):Script(entity) {
            character = entity->getComponent<physics::CapsuleCharacterController>();
        }
        
        void targetCamera(EntityPtr camera) {
            Canvas::key_callbacks.push_back([&](GLFWwindow *window, int key, int scancode, int action, int mods){
                Float3 forward = entity()->transform->position() - camera->transform->position();
                forward.y = 0;
                forward = Normalize(forward);
                Float3 cross = Float3(forward.z, 0, -forward.x);
                
                switch (key) {
                    case GLFW_KEY_W:
                        displacement = forward * 0.3;
                        break;
                    case GLFW_KEY_S:
                        displacement = -forward * 0.3;
                        break;
                    case GLFW_KEY_A:
                        displacement = cross * 0.3;
                        break;
                    case GLFW_KEY_D:
                        displacement = -cross * 0.3;
                        break;
                    case GLFW_KEY_SPACE:
                        displacement.x = 0;
                        displacement.y = 2;
                        displacement.z = 0;
                        break;
                    default:
                        break;
                }
            });
        }
        
        void onUpdate(float deltaTime) override {
            auto flags = character->move(displacement, 0.1, deltaTime);
            displacement = Float3();
            if (!flags.isSet(physx::PxControllerCollisionFlag::Enum::eCOLLISION_DOWN)) {
                character->move(Float3(0, -0.2, 0), 0.1, deltaTime);
            }
        }
        
    private:
        physics::CharacterController* character = nullptr;
        Float3 displacement = Float3();
    };
    
    auto transform = [&](const math::Float3 &position, const math::Quaternion &rotation,
                         math::Float3 &outPosition, math::Quaternion &outRotation) {
        outRotation = rotation * outRotation;
        outPosition = math::transformByQuat(outPosition, rotation);
        outPosition = outPosition + position;
    };
    
    auto createChain = [&](const math::Float3 &position, const math::Quaternion &rotation, size_t length, float separation) {
        auto offset = math::Float3(0, -separation / 2, 0);
        physics::DynamicCollider *prevCollider = nullptr;
        for (size_t i = 0; i < length; i++) {
            auto localTm_pos = math::Float3(0, -separation / 2 * (2 * float(i) + 1), 0);
            auto localTm_quat = math::Quaternion();
            transform(position, rotation, localTm_pos, localTm_quat);
            
            auto currentEntity = addBox(math::Float3(2.0, 2.0, 0.5), localTm_pos, localTm_quat);
            auto currentCollider = currentEntity->getComponent<physics::DynamicCollider>();
            
            auto joint = physics::FixedJoint(prevCollider, currentCollider);
            math::Transform localPose;
            localPose.translation = prevCollider != nil ? offset : position;
            localPose.rotation = prevCollider != nil ? Quaternion() : rotation;
            joint.setLocalPose(physx::PxJointActorIndex::Enum::eACTOR0, localPose);
            localPose.translation = math::Float3(0, separation / 2, 0);
            localPose.rotation = Quaternion();
            joint.setLocalPose(physx::PxJointActorIndex::Enum::eACTOR1, localPose);
            prevCollider = currentCollider;
        }
    };
    
    auto light = rootEntity->createChild("light");
    light->transform->setPosition(10, 10, 0);
    light->transform->lookAt(Float3());
    auto directLight = light->addComponent<DirectLight>();
    directLight->intensity = 1.0;
    directLight->setEnableShadow(true);
    
    auto player = addPlayer(1, 3, Float3(0, 6.5, 0), Quaternion());
    auto controller = player->addComponent<ControllerScript>();
    controller->targetCamera(cameraEntity);
    
    addPlane(math::Float3(30, 0.1, 30), math::Float3(), math::Quaternion());
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            addBox(math::Float3(1, 1, 1),
                   math::Float3(-2.5 + i + 0.1 * i, u(e) * 6.f + 1, -2.5 + j + 0.1 * j),
                   Quaternion(0, 0, 0.3, 0.7));
        }
    }
    createChain(math::Float3(0.0, 25.0, -10.0), math::Quaternion(), 10, 2.0);
    
    Canvas::mouse_button_callbacks.push_back([&](GLFWwindow *window, int button, int action, int mods){
        double xpos, ypos;
        glfwGetCursorPos(window, &xpos, &ypos);
        auto camera = cameraEntity->getComponent<Camera>();
        Ray ray = camera->screenPointToRay(Float2(xpos, ypos));

        physics::HitResult hit;
        auto result = engine._physicsManager.raycast(ray, std::numeric_limits<float>::max(), Layer::Layer0, hit);
        if (result) {
            auto mtl = std::make_shared<BlinnPhongMaterial>(&engine);
            mtl->setBaseColor(math::Color(u(e), u(e), u(e), 1));
  
            auto meshes = hit.entity->getComponentsIncludeChildren<MeshRenderer>();
            for (auto& mesh : meshes) {
                mesh->setMaterial(mtl);
            }
        }
    });
    
    Canvas::key_callbacks.push_back([&](GLFWwindow *window, int key, int scancode, int action, int mods){
        if (action == GLFW_RELEASE) {
            Float3 dir = cameraEntity->transform->worldForward();
            dir = dir * 50;
            
            switch (key) {
                case GLFW_KEY_ENTER:
                    addSphere(0.5, cameraEntity->transform->position(),
                              cameraEntity->transform->rotationQuaternion(), dir);
                    break;
                default:
                    break;
            }
        }
    });
    
    engine.run();
};
