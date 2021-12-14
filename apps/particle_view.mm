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

using namespace vox;

class ParticleMaterial: public BaseMaterial {
public:
    ParticleMaterial(Engine* engine):BaseMaterial(engine, Shader::find("particle-shader")) {}
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

    engine.run();
}
