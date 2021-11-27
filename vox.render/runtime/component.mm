//
//  component.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "component.h"
#include "entity.h"

namespace vox {
Component::Component(Entity *entity) : EngineObject(entity->engine()), _entity(entity) {
}

bool Component::enabled() {
    return _enabled;
}

void Component::setEnabled(bool value) {
    if (value == _enabled) {
        return;
    }
    _enabled = value;
    if (value) {
        if (_entity->isActiveInHierarchy()) {
            _onEnable();
        }
    } else {
        if (_entity->isActiveInHierarchy()) {
            _onDisable();
        }
    }
}

bool Component::destroyed() {
    return _destroyed;
}

Entity *Component::entity() {
    return _entity;
}

ScenePtr Component::scene() {
    return _entity->scene();
}

void Component::destroy() {
    if (_destroyed) {
        return;
    }
    _entity->_removeComponent(this);
    if (_entity->isActiveInHierarchy()) {
        if (_enabled) {
            _onDisable();
        }
        _onInActive();
    }
    _destroyed = true;
    _onDestroy();
}

void Component::_setActive(bool value) {
    if (value) {
        if (!_awoken) {
            _awoken = true;
            _onAwake();
        }
        // You can do isActive = false in onAwake function.
        if (_entity->_isActiveInHierarchy) {
            _onActive();
            if (_enabled) {
                _onEnable();
            }
        }
    } else {
        if (_enabled) {
            _onDisable();
        }
        _onInActive();
    }
}

}
