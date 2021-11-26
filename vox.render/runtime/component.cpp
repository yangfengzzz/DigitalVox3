//
//  component.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "component.h"
#include "entity.h"

namespace vox {
Component::Component(Entity* entity):EngineObject(entity->engine()), _entity(entity) {
}
}
