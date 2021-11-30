//
//  script.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "script.h"
#include "engine.h"

namespace vox {
Script::Script(Entity* entity):
Component(entity) {
    
}

void Script::_onAwake() {
    onAwake();
}

void Script::_onEnable() {
    auto& componentsManager = engine()->_componentsManager;
    if (!_started) {
        componentsManager.addOnStartScript(this);
    }
    componentsManager.addOnUpdateScript(this);
    componentsManager.addOnLateUpdateScript(this);
    _entity->_addScript(this);
    onEnable();
}

void Script::_onDisable() {
    auto& componentsManager = engine()->_componentsManager;
    // Use "xxIndex" is more safe.
    // When call onDisable it maybe it still not in script queue,for example write "entity.isActive = false" in onWake().
    if (_onStartIndex != -1) {
        componentsManager.removeOnStartScript(this);
    }
    if (_onUpdateIndex != -1) {
        componentsManager.removeOnUpdateScript(this);
    }
    if (_onLateUpdateIndex != -1) {
        componentsManager.removeOnLateUpdateScript(this);
    }
    if (_entityCacheIndex != -1) {
        _entity->_removeScript(this);
    }
    onDisable();
}

void Script::_onDestroy() {
    engine()->_componentsManager.addDestroyComponent(this);
}


}
