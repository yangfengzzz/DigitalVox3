//
//  components_manager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "components_manager.h"
#include "script.h"

namespace vox {
void ComponentsManager::addOnStartScript(Script* script) {
    script->_onStartIndex = _onStartScripts.size();
    _onStartScripts.push_back(script);
}

void ComponentsManager::removeOnStartScript(Script* script) {
    _onStartScripts.erase(_onStartScripts.begin() + script->_onStartIndex);
    script->_onStartIndex = -1;
}

std::vector<Component *> ComponentsManager::getActiveChangedTempList() {
    return _componentsContainerPool.size() ? *(_componentsContainerPool.end() - 1) : std::vector<Component *>{};
}

void ComponentsManager::putActiveChangedTempList(std::vector<Component *> &componentContainer) {
    componentContainer.clear();
    _componentsContainerPool.push_back(componentContainer);
}

void ComponentsManager::addOnUpdateScript(Script* script) {
    script->_onUpdateIndex = _onUpdateScripts.size();
    _onUpdateScripts.push_back(script);
}

void ComponentsManager::removeOnUpdateScript(Script* script) {
    _onUpdateScripts.erase(_onUpdateScripts.begin() + script->_onUpdateIndex);
    script->_onUpdateIndex = -1;
}

void ComponentsManager::addOnLateUpdateScript(Script* script) {
    script->_onLateUpdateIndex = _onLateUpdateScripts.size();
    _onLateUpdateScripts.push_back(script);
}

void ComponentsManager::removeOnLateUpdateScript(Script* script) {
    _onLateUpdateScripts.erase(_onLateUpdateScripts.begin() + script->_onLateUpdateIndex);
    script->_onLateUpdateIndex = -1;
}

void ComponentsManager::callScriptOnStart() {
    auto& onStartScripts = _onStartScripts;
    if (onStartScripts.size() > 0) {
        // The 'onStartScripts.length' maybe add if you add some Script with addComponent() in some Script's onStart()
        for (size_t i = 0; i < onStartScripts.size(); i++) {
            const auto& script = onStartScripts[i];
            script->_started = true;
            script->_onStartIndex = -1;
            script->onStart();
        }
        onStartScripts.clear();
    }
}

void ComponentsManager::callScriptOnUpdate(float deltaTime) {
    const auto& onUpdateScripts = _onUpdateScripts;
    for (size_t i = _onUpdateScripts.size() - 1; i >= 0; --i) {
        const auto& element = onUpdateScripts[i];
        if (element->_started) {
            element->onUpdate(deltaTime);
        }
    }
}

void ComponentsManager::callScriptOnLateUpdate(float deltaTime) {
    const auto& onLateUpdateScripts = _onLateUpdateScripts;
    for (size_t i = _onLateUpdateScripts.size() - 1; i >= 0; --i) {
        const auto& element = onLateUpdateScripts[i];
        if (element->_started) {
            element->onLateUpdate(deltaTime);
        }
    }
}

}
