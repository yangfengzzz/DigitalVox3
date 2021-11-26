//
//  entity.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "entity.h"
#include "scene.h"

namespace vox {
EntityPtr Entity::_findChildByName(EntityPtr root, const std::string& name) {
    const auto& children = root->_children;
    for (size_t i = children.size() - 1; i >= 0; i--) {
        const auto& child = children[i];
        if (child->name == name) {
            return child;
        }
    }
    return nullptr;
}

void Entity::_traverseSetOwnerScene(EntityPtr entity, std::optional<std::weak_ptr<Scene>> scene) {
    entity->_scene = scene;
    const auto& children = entity->_children;
    for (size_t i = entity->_children.size() - 1; i >= 0; i--) {
        _traverseSetOwnerScene(children[i], scene);
    }
}

Entity::Entity(EnginePtr engine, std::string name) : EngineObject(engine), name(name) {
    transform = addComponent<Transform>();
    _inverseWorldMatFlag = transform->registerWorldChangeFlag();
}

bool Entity::isActive() {
    return _isActive;
}

void Entity::setIsActive(bool value) {
    if (value != _isActive) {
        _isActive = value;
        if (value) {
            const auto& parent = _parent;
            if ((parent->lock() != nullptr && parent->lock()->_isActiveInHierarchy)
                || (_isRoot && _scene->lock()->_isActiveInEngine)) {
                _processActive();
            }
        } else {
            if (_isActiveInHierarchy) {
                _processInActive();
            }
        }
    }
}

bool Entity::isActiveInHierarchy() {
    return _isActiveInHierarchy;
}

EntityPtr Entity::parent() {
    return _parent->lock();
}

void Entity::setParent(EntityPtr entity) {
    if (entity != _parent->lock()) {
        const auto oldParent = _removeFromParent();
        auto newParent = _parent = entity;
        auto thisPtr = std::shared_ptr<Entity>(this);
        if (newParent->lock()) {
            newParent->lock()->_children.push_back(thisPtr);
            const auto parentScene = newParent->lock()->_scene;
            if (_scene->lock() != parentScene->lock()) {
                Entity::_traverseSetOwnerScene(thisPtr, parentScene);
            }
            
            if (newParent->lock()->_isActiveInHierarchy) {
                if (!_isActiveInHierarchy && _isActive) {
                    _processActive();
                }
            } else {
                if (_isActiveInHierarchy) {
                    _processInActive();
                }
            }
        } else {
            if (_isActiveInHierarchy) {
                _processInActive();
            }
            if (oldParent) {
                Entity::_traverseSetOwnerScene(thisPtr, std::nullopt);
            }
        }
        _setTransformDirty();
    }
}

const std::vector<EntityPtr> Entity::children() const {
    return _children;
}

size_t Entity::childCount() {
    return _children.size();
}

ScenePtr Entity::scene() {
    return _scene->lock();
}



}
