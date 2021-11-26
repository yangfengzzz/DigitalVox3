//
//  engine_object.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "engine_object.h"

namespace vox {
int EngineObject::_instanceIdCounter = 0;

EngineObject::EngineObject(EnginePtr engine):_engine(engine) {
}

int EngineObject::instanceId(){
    ++EngineObject::_instanceIdCounter;
    return EngineObject::_instanceIdCounter;
}

EnginePtr EngineObject::engine() {
    return _engine;
}

}
