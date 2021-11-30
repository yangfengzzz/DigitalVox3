//
//  orbit_control.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/30.
//

#include "orbit_control.h"
#include "../engine.h"

namespace vox {
namespace control {
OrbitControl::OrbitControl(Entity* entity):
Script(entity),
camera(entity) {
    windows = engine()->canvas().handle();
}


}
}
