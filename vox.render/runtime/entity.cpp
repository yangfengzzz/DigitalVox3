//
//  entity.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "entity.h"
#include "scene.h"

namespace vox {
Entity::Entity(EnginePtr engine, std::string name) : EngineObject(engine), name(name) {
    transform = addComponent<Transform>();
    _inverseWorldMatFlag = transform->registerWorldChangeFlag();
}

void Entity::setIsActive(bool value) {
    if (value != _isActive) {
        _isActive = value;
        if (value) {
            const auto& parent = _parent;
            if ((parent.lock() != nullptr && parent.lock()->_isActiveInHierarchy)
                || (_isRoot && _scene.lock()->_isActiveInEngine)) {
                _processActive();
            }
        } else {
            if (_isActiveInHierarchy) {
                _processInActive();
            }
        }
    }
}

}
