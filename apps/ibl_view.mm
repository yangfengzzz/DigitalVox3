//
//  ibl_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/12/19.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/primitive_mesh.h"
#include "../vox.render/runtime/material/pbr_material.h"
#include "../vox.render/runtime/controls/orbit_control.h"
#include "../vox.render/runtime/lighting/direct_light.h"
#include "../vox.render/runtime/sky/skybox_material.h"
#include <random>

using namespace vox;

int main(int, char **) {
    struct Material {
        std::string name;
        math::Color baseColor;
        float roughness;
        float metallic;
        
        Material() {
        };
        
        Material(std::string n, math::Color c, float r, float m) : name(n) {
            roughness = r;
            metallic = m;
            baseColor = c;
        };
    };
    std::vector<Material> materials(11);
    materials[0] = Material("Gold", math::Color(1.0f, 0.765557f, 0.336057f, 1.0), 0.1f, 1.0f);
    materials[1] = Material("Copper", math::Color(0.955008f, 0.637427f, 0.538163f, 1.0), 0.1f, 1.0f);
    materials[2] = Material("Chromium", math::Color(0.549585f, 0.556114f, 0.554256f, 1.0), 0.1f, 1.0f);
    materials[3] = Material("Nickel", math::Color(0.659777f, 0.608679f, 0.525649f, 1.0), 0.1f, 1.0f);
    materials[4] = Material("Titanium", math::Color(0.541931f, 0.496791f, 0.449419f, 1.0), 0.1f, 1.0f);
    materials[5] = Material("Cobalt", math::Color(0.662124f, 0.654864f, 0.633732f, 1.0), 0.1f, 1.0f);
    materials[6] = Material("Platinum", math::Color(0.672411f, 0.637331f, 0.585456f, 1.0), 0.1f, 1.0f);
    // Testing materials
    materials[7] = Material("White", math::Color(1.0f, 1.0, 1.0, 1.0), 0.1f, 1.0f);
    materials[8] = Material("Red", math::Color(1.0f, 0.0f, 0.0f, 1.0), 0.1f, 1.0f);
    materials[9] = Material("Blue", math::Color(0.0f, 0.0f, 1.0f, 1.0), 0.1f, 1.0f);
    materials[10] = Material("Black", math::Color(0.0f, 1.0, 1.0, 1.0), 0.1f, 1.0f);
    
    const int materialIndex = 7;
    Material mat = materials[materialIndex];
    
    const std::string path =
    "/Users/yangfeng/Desktop/met-materials/12-environment/projects/resources/IrradianceGenerator/IrradianceGenerator/Sky Images";
    const std::array<std::string, 6> images = {"posx.png", "negx.png", "posy.png", "negy.png", "posz.png", "negz.png"};
    
    auto canvas = std::make_unique<Canvas>(1280, 720, "vox.render");
    auto engine = Engine(canvas.get());
    auto resourceLoader = engine.resourceLoader();
    auto scene = engine.sceneManager().activeScene();
    scene->background.mode = BackgroundMode::Enum::Sky;
    
    auto skyMaterial = std::make_shared<SkyBoxMaterial>(&engine);
    skyMaterial->setTextureCubeMap(resourceLoader->loadCubeTexture(path, images));
    scene->background.sky.material = skyMaterial;
    scene->background.sky.mesh = PrimitiveMesh::createCuboid(&engine, 1, 1, 1);
    
    auto specularTexture = resourceLoader->createSpecularTexture(path, images);
    scene->ambientLight().setSpecularTexture(specularTexture);
    
    auto diffuseTexture = resourceLoader->createIrradianceTexture(path, images);
    scene->ambientLight().setDiffuseTexture(diffuseTexture);
    
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    cameraEntity->transform->setPosition(10, 10, 10);
    cameraEntity->transform->lookAt(Float3(0, 0, 0));
    cameraEntity->addComponent<vox::Camera>();
    cameraEntity->addComponent<control::OrbitControl>();
    
    // init point light
    auto light = rootEntity->createChild("light");
    light->transform->setPosition(-3, 3, -3);
    light->transform->lookAt(Float3(0, 0, 0));
    auto directionLight = light->addComponent<DirectLight>();
    directionLight->intensity = 0.3;
    
    auto sphere = PrimitiveMesh::createSphere(&engine, 0.5, 64);
    for (int i = 0; i < 7; i++) {
        for (int j = 0; j < 7; j++) {
            auto sphereEntity = rootEntity->createChild("SphereEntity" + std::to_string(i) + std::to_string(j));
            sphereEntity->transform->setPosition(math::Float3(i - 3, j - 3, 0));
            auto sphereMtl = std::make_shared<PBRMaterial>(&engine);
            sphereMtl->setBaseColor(mat.baseColor);
            sphereMtl->setMetallic(Clamp(float(7 - i) / float(7 - 1), 0.1f, 1.0f));
            sphereMtl->setRoughness(Clamp(float(7 - j) / float(7 - 1), 0.05f, 1.0f));
            
            auto sphereRenderer = sphereEntity->addComponent<MeshRenderer>();
            sphereRenderer->setMesh(sphere);
            sphereRenderer->setMaterial(sphereMtl);
        }
    }
    
    engine.run();
}
