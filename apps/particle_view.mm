//
//  particle_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/14.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/material/base_material.h"
#include "../vox.render/runtime/material/blinn_phong_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/lighting/point_light.h"
#include "../vox.render/runtime/particle/particle_renderer.h"

#include "../vox.geometry/surfaces/plane.h"
#include "../vox.geometry/colliders/rigid_body_collider.h"
#include "../vox.geometry/particle_emitter/point_particle_emitter3.h"

#include <random>

using namespace vox;

class ParticleMaterial : public BaseMaterial {
public:
    ParticleMaterial(Engine *engine) : BaseMaterial(engine, Shader::find("particle-shader")) {
        setIsTransparent(true);
        auto texture = engine->_hardwareRenderer.loadTexture("../models/particle_smoke.ktx");
        shaderData.setData(ParticleMaterial::_baseTextureProp, texture);
    }
    
private:
    ShaderProperty _baseTextureProp = Shader::createProperty("u_particleTexture", ShaderDataGroup::Material);
};

class ParticleScript : public Script {
public:
    ParticleScript(Entity *entity) : Script(entity) {
        _renderer = entity->getComponent<ParticleRenderer>();
        _particleSystemData = _renderer->particleSystemData();
    }
    
    void onStart() override {
        geometry::Plane3Ptr plane = std::make_shared<geometry::Plane3>(geometry::Vector3D(0, 1, 0), geometry::Vector3D());
        geometry::RigidBodyCollider3Ptr collider = std::make_shared<geometry::RigidBodyCollider3>(plane);
        collider->setFrictionCoefficient(0.01);
        
        _solver = std::make_shared<geometry::ParticleSystemSolver3>();
        _solver->setRestitutionCoefficient(0.5);
        _solver->setCollider(collider);
        
        geometry::PointParticleEmitter3Ptr emitter =
        std::make_shared<geometry::PointParticleEmitter3>(geometry::Vector3D(0, 0, 0),
                                                          geometry::Vector3D(0, 1, 0), 10.0, 15.0);
        emitter->setMaxNumberOfNewParticlesPerSecond(100);
        emitter->setMaxNumberOfParticles(1000);
        _solver->setEmitter(emitter);
        
        _renderer->setParticleSystemSolver(_solver);
    }
    
private:
    std::default_random_engine e{};
    std::uniform_real_distribution<float> u = std::uniform_real_distribution<float>(-0.5, 0.5);
    geometry::ParticleSystemSolver3Ptr _solver;
    
    ParticleRenderer *_renderer;
    geometry::ParticleSystemData3Ptr _particleSystemData;
};

int main(int, char **) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    scene->ambientLight().setDiffuseSolidColor(math::Color(1, 1, 1));
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(5, 5, 5);
    cameraEntity->transform->lookAt(Float3(0, 0, 0));
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    auto particleEntity = rootEntity->createChild("particle");
    auto particles = particleEntity->addComponent<ParticleRenderer>();
    auto pMtl = std::make_shared<ParticleMaterial>(&engine);
    particles->setMaterial(pMtl);
    
    particleEntity->addComponent<ParticleScript>();
    
    auto planeEntity = rootEntity->createChild("PlaneEntity");
    auto planeMtl = std::make_shared<BlinnPhongMaterial>(&engine);
    planeMtl->setBaseColor(math::Color(0.5, 0.5, 0.5, 1.0));
    planeMtl->setRenderFace(RenderFace::Enum::Double);
    
    auto planeRenderer = planeEntity->addComponent<MeshRenderer>();
    planeRenderer->setMesh(PrimitiveMesh::createPlane(&engine, 10, 10));
    planeRenderer->setMaterial(planeMtl);
    
    engine.run();
}
