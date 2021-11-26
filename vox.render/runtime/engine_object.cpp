//
//  engine_object.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "engine_object.h"

namespace ozz {
int EngineObject::_instanceIdCounter = 0;

int EngineObject::getInstanceId(){
    ++EngineObject::_instanceIdCounter;
    return EngineObject::_instanceIdCounter;
}

EnginePtr EngineObject::getEngine() {
    return _engine;
}

EngineObject::EngineObject(EnginePtr engine):_engine(engine) {
}

}
