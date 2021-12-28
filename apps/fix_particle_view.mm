//
//  particle_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/13.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/material/unlit_material.h"
#include "../vox.render/runtime/material/blinn_phong_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/lighting/point_light.h"
#include "../vox.render/runtime/particle/particle_renderer.h"

using namespace vox;

int main(int, char **) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    scene->ambientLight().setDiffuseSolidColor(math::Color(1, 1, 1));
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(0, 0, 50);
    cameraEntity->transform->lookAt(Float3(0, 0, 0));
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    auto particleEntity = rootEntity->createChild("particle");
    auto particles = particleEntity->addComponent<ParticleRenderer>();
    particles->setMaxCount(100);
    particles->setStartTimeRandomness(10);
    particles->setLifetime(4);
    particles->setPosition(Float3(0, 20, 0));
    particles->setPositionRandomness(Float3(100, 0, 0));
    particles->setVelocity(Float3(0, -3, 0));
    particles->setVelocityRandomness(Float3(1, 2, 0));
    particles->setAccelerationRandomness(Float3(0, 1, 0));
    particles->setVelocityRandomness(Float3(-1, -1, -1));
    particles->setRotateVelocity(1);
    particles->setRotateVelocityRandomness(1);
    particles->setSize(1);
    particles->setSizeRandomness(0.8);
    particles->setColor(Color(0.5, 0.5, 0.5));
    particles->setColorRandomness(1);
    particles->setIsFadeIn(true);
    particles->setIsFadeOut(true);
    particles->start();
    
    engine.run();
}
