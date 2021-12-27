//
//  modelio_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/27.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/gpu_skinned_mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/animator.h"
#include "../vox.render/runtime/scene_animator.h"
#include "../vox.render/runtime/material/unlit_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/controls/free_control.h"
#include "../vox.render/runtime/lighting/point_light.h"
#include "../vox.render/runtime/lighting/direct_light.h"
#include "../vox.render/runtime/particle/particle_renderer.h"
#include "../vox.render/offline/modelio_loader.h"

using namespace vox;

class SkyMove: public Script {
public:
    SkyMove(Entity* entity):Script(entity) {}
    
    void onUpdate(float deltaTime) override {
        skyRotation += 0.5f;
        entity()->transform->setRotation(0, skyRotation, 0);
    }
    
private:
    float skyRotation = -135;
};

class SunMove: public Script {
public:
    SunMove(Entity* entity):Script(entity) {
        entity->transform->setPosition(0.25, 0.5, -1.0);
    }
    
    void onUpdate(float deltaTime) override {
        entity()->transform->lookAt(Float3());
    }
};

class ParticleMaterial: public BaseMaterial {
public:
    ParticleMaterial(Engine* engine):BaseMaterial(engine, Shader::find("particle-shader")) {
        setIsTransparent(true);
    }
    
private:
    ShaderProperty _baseTextureProp = Shader::createProperty("u_particleTexture", ShaderDataGroup::Material);
};

class PointLightManager: public Script {
public:
    static constexpr uint32_t numLights = 100;
    // 30% of lights are around the tree
    // 40% of lights are on the ground inside the columns
    // 30% of lights are around the outside of the columns
    static constexpr uint32_t treeLights   = 0 + 0.30 * numLights;
    static constexpr uint32_t groundLights = treeLights + 0.40 * numLights;
    static constexpr uint32_t columnLights = groundLights + 0.30 * numLights;
    
    // Generates a random float value inside the given range.
    inline static float random_float(float min, float max) {
        return (((double)random()/RAND_MAX) * (max-min)) + min;
    }
    
    PointLightManager(Entity* entity):Script(entity) {
        lightEntities.reserve(numLights);
        speeds.reserve(numLights);
        particle = entity->addComponent<ParticleRenderer>();
        particle->setMaterial(std::make_shared<ParticleMaterial>(engine()));
        particle->particleSystemData()->resize(numLights);
        for (uint32 lightId = 0; lightId < numLights; lightId++) {
            auto lightEntity = entity->createChild("PointLight" + std::to_string(lightId));
            lightEntities.push_back(lightEntity);
            auto light = lightEntity->addComponent<PointLight>();
            float distance = 0;
            float height = 0;
            float angle = 0;
            float speed = 0;
            
            if (lightId < treeLights) {
                distance = random_float(38,42);
                height = random_float(0,1);
                angle = random_float(0, M_PI*2);
                speed = random_float(0.003,0.014);
            } else if (lightId < groundLights) {
                distance = random_float(140,260);
                height = random_float(140,150);
                angle = random_float(0, M_PI*2);
                speed = random_float(0.006,0.027);
                speed *= (random()%2)*2-1;
            } else if (lightId < columnLights) {
                distance = random_float(365,380);
                height = random_float(150,190);
                angle = random_float(0, M_PI*2);
                speed = random_float(0.004,0.014);
                speed *= (random()%2)*2-1;
            }
            speed *= .05;
            lightEntity->transform->setPosition(distance*sinf(angle), height, distance*cosf(angle));
            auto worldPos = lightEntity->transform->worldPosition();
            particle->particleSystemData()->positions()[lightId].x = worldPos.x;
            particle->particleSystemData()->positions()[lightId].y = worldPos.y;
            particle->particleSystemData()->positions()[lightId].z = worldPos.z;
            
            light->distance = random_float(25,35)/10.0;
            speeds.push_back(speed);
            
            int colorId = random()%3;
            if( colorId == 0) {
                light->color = Color(random_float(4,6),random_float(0,4),random_float(0,4));
            } else if ( colorId == 1) {
                light->color = Color(random_float(0,4),random_float(4,6),random_float(0,4));
            } else {
                light->color = Color(random_float(0,4),random_float(0,4),random_float(4,6));
            }
        }
    }
    
    void onUpdate(float deltaTime) override {
        for (uint32 lightId = 0; lightId < numLights; lightId++) {
            Float3 originalLightPositions = lightEntities[lightId]->transform->position();
            Float3 currentPosition;
            if (lightId < treeLights) {
                double lightPeriod = speeds[lightId] * totalTime;
                lightPeriod += originalLightPositions.y;
                lightPeriod -= floor(lightPeriod);  // Get fractional part
                
                // Use pow to slowly move the light outward as it reaches the branches of the tree
                float r = 1.2 + 10.0 * powf(lightPeriod, 5.0);
                currentPosition.x = originalLightPositions.x * r;
                currentPosition.y = 200.0f + lightPeriod * 400.0f;
                currentPosition.z = originalLightPositions.z * r;
            } else {
                float rotationRadians = speeds[lightId] * totalTime;
                auto rotMat = Matrix::rotationAxisAngle(Float3(0, 1, 0), rotationRadians);
                currentPosition = transformCoordinate(originalLightPositions, rotMat);
            }
            lightEntities[lightId]->transform->setPosition(currentPosition);
            auto worldPos = lightEntities[lightId]->transform->worldPosition();
            particle->particleSystemData()->positions()[lightId].x = worldPos.x;
            particle->particleSystemData()->positions()[lightId].y = worldPos.y;
            particle->particleSystemData()->positions()[lightId].z = worldPos.z;
        }
        totalTime += deltaTime;
    }
    
private:
    float totalTime = 0;
    std::vector<EntityPtr> lightEntities;
    std::vector<float> speeds;
    ParticleRenderer* particle;
};

int main(int, char**) {
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto scene = engine.sceneManager().activeScene();
    scene->background.solidColor = math::Color(0.3, 0.7, 0.6, 1.0);
    scene->ambientLight().setDiffuseSolidColor(math::Color(0.0,0.0,0.0));
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(-6.02535057, 36.6681671, 48.6991844);
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    auto sky = rootEntity->createChild("sky");
    sky->addComponent<SkyMove>();
    auto sun = sky->createChild("sun");
    sun->addComponent<SunMove>();
    auto diretLight = sun->addComponent<DirectLight>();
    diretLight->shadow.intensity = 0.4;
    diretLight->intensity = 1.0;
    diretLight->setEnableShadow(true);
    
    auto loader = offline::ModelIOLoader(&engine);
    loader.loadFromFile("../models/Temple", "Temple.obj");
    loader.defaultSceneRoot->transform->setScale(0.05, 0.05, 0.05);
    loader.defaultSceneRoot->transform->setPosition(0, -10, 0);
    for (auto& renderer : loader.renderers) {
        renderer->castShadow = true;
        renderer->receiveShadow = true;
    }
    loader.defaultSceneRoot->addComponent<PointLightManager>();
    rootEntity->addChild(loader.defaultSceneRoot);
    
    engine.run();
}
