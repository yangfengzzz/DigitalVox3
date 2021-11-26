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

void Entity::addChild(EntityPtr child) {
    child->setParent(EntityPtr(this));
}

void Entity::removeChild(EntityPtr child) {
    child->setParent(nullptr);
}

EntityPtr Entity::getChild(int index) {
    return _children[index];
}

EntityPtr Entity::findByName(const std::string& name) {
    const auto& children = _children;
    const auto child = Entity::_findChildByName(EntityPtr(this), name);
    if (child) return child;
    for (size_t i = children.size() - 1; i >= 0; i--) {
        const auto& child = children[i];
        const auto grandson = child->findByName(name);
        if (grandson) {
            return grandson;
        }
    }
    return nullptr;
}

EntityPtr Entity::createChild(const std::string& name) {
    auto child = std::make_shared<Entity>(engine(), name);
    child->layer = layer;
    child->setParent(EntityPtr(this));
    return child;
}

void Entity::clearChildren() {
    auto& children = _children;
    for (size_t i = children.size() - 1; i >= 0; i--) {
        const auto& child = children[i];
        child->_parent = std::nullopt;
        if (child->_isActiveInHierarchy) {
            child->_processInActive();
        }
        Entity::_traverseSetOwnerScene(child, std::nullopt); // Must after child._processInActive().
    }
    children.clear();
}

EntityPtr Entity::clone() {
    auto cloneEntity = std::make_shared<Entity>(_engine, name);
    
    cloneEntity->_isActive = _isActive;
    cloneEntity->transform->setLocalMatrix(transform->localMatrix());
    
    const auto& children = _children;
    for (size_t i = 0, len = _children.size(); i < len; i++) {
        const auto& child = children[i];
        cloneEntity->addChild(child->clone());
    }
    
    const auto& components = _components;
    for (size_t i = 0, n = components.size(); i < n; i++) {
        const auto& sourceComp = components[i];
        if (!(dynamic_cast<Transform*>(sourceComp.get()))) {
            // TODO
        }
    }
    
    return cloneEntity;
}

void Entity::destroy() {
    auto& abilityArray = _components;
    for (size_t i = abilityArray.size() - 1; i >= 0; i--) {
        abilityArray[i]->destroy();
    }
    _components.clear();
    
    const auto& children = _children;
    for (size_t i = children.size() - 1; i >= 0; i--) {
        children[i]->destroy();
    }
    _children.clear();
    
    if (_parent != std::nullopt) {
        auto& parentChildren = _parent->lock()->_children;
        parentChildren.erase(std::remove(parentChildren.begin(),
                                         parentChildren.end(), EntityPtr(this)), parentChildren.end());
    }
    _parent = std::nullopt;
}

void Entity::_removeComponent(Component* component) {
    // ComponentsDependencies._removeCheck(this, component.constructor as any);
    auto& components = _components;
    components.erase(std::remove(components.begin(),
                                 components.end(), component), components.end());
}

void Entity::_addScript(Script* script) {
    script->_entityCacheIndex = _scripts.size();
    _scripts.push_back(script);
}

void Entity::_removeScript(Script* script) {
    std::remove(_scripts.begin(), _scripts.end(), script);
    script->_entityCacheIndex = -1;
}

EntityPtr Entity::_removeFromParent() {
    const auto& oldParent = _parent;
    if (oldParent != std::nullopt) {
        auto& oldParentChildren = oldParent->lock()->_children;
        oldParentChildren.erase(std::remove(oldParentChildren.begin(),
                                            oldParentChildren.end(), EntityPtr(this)), oldParentChildren.end());
        _parent = std::nullopt;
    }
    return oldParent->lock();
}

void Entity::_processActive() {
    _activeChangedComponents = _engine->_componentsManager.getActiveChangedTempList();
    _setActiveInHierarchy(_activeChangedComponents);
    _setActiveComponents(true);
}

void Entity::_processInActive() {
    _activeChangedComponents = _engine->_componentsManager.getActiveChangedTempList();
    _setInActiveInHierarchy(_activeChangedComponents);
    _setActiveComponents(false);
}

}
