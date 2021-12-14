//
//  particle_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/14.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/material/base_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/lighting/point_light.h"
#include "../vox.render/runtime/particle/particle_renderer.h"
#include <random>

using namespace vox;

class ParticleMaterial: public BaseMaterial {
public:
    ParticleMaterial(Engine* engine):BaseMaterial(engine, Shader::find("particle-shader")) {}
};

class ParticleScript: public Script {
public:
    ParticleScript(Entity* entity):Script(entity) {
        _renderer = entity->getComponent<ParticleRenderer>();
        _particleSystemData = _renderer->particleSystemData();
    }
    
    void onStart() override {
        auto position = _particleSystemData->positions();
        for (auto& pos : position) {
            pos.x = u(e) * 50;
            pos.y = u(e) * 10;
        }
    }
    
private:
    std::default_random_engine e{};
    std::uniform_real_distribution<float> u = std::uniform_real_distribution<float>(-0.5, 0.5);
    
    ParticleRenderer* _renderer;
    geometry::ParticleSystemData3Ptr _particleSystemData;
};

int main(int, char**) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    scene->ambientLight().setDiffuseSolidColor(math::Color(1,1,1));
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(0, 0, 50);
    cameraEntity->transform->lookAt(Float3(0, 0, 0));
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    auto particleEntity = rootEntity->createChild("particle");
    auto particles = particleEntity->addComponent<ParticleRenderer>();
    particles->particleSystemData()->resize(100);
    auto pMtl = std::make_shared<ParticleMaterial>(&engine);
    particles->setMaterial(pMtl);
    
    particleEntity->addComponent<ParticleScript>();

    engine.run();
}
