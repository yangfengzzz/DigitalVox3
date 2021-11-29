//
//  windows_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/11/29.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/camera.h"

using namespace vox;

int main(int, char**) {
    auto canvas = Canvas(720, 1080, "vox.render");
    auto engine = Engine(canvas);
    auto scene = engine.sceneManager().activeScene();
    auto rootEntity = scene->createRootEntity();
    auto cameraEntity = rootEntity->createChild("camera");
    auto camera = cameraEntity->addComponent<vox::Camera>();

    engine.run();
}
