//
//  windows_view.cpp
//  apps
//
//  Created by 杨丰 on 2021/11/29.
//

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/engine.h"

using namespace vox;

int main(int, char**) {
    auto canvas = Canvas(720, 1080, "vox.render");
    auto engine = Engine(canvas);
    auto scene = engine.sceneManager().activeScene();
    auto rootEntity = scene->createRootEntity();

    engine.run();
}
