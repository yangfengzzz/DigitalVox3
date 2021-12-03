//
//  entity.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "entity.h"
#include "scene.h"
#include "engine.h"

namespace vox {
EntityPtr Entity::_findChildByName(Entity* root, const std::string &name) {
    const auto &children = root->_children;
    for (size_t i = 0; i < children.size(); i++) {
        const auto &child = children[i];
        if (child->name == name) {
            return child;
        }
    }
    return nullptr;
}

void Entity::_traverseSetOwnerScene(Entity* entity, Scene* scene) {
    entity->_scene = scene;
    const auto &children = entity->_children;
    for (size_t i = 0; i < entity->_children.size(); i++) {
        _traverseSetOwnerScene(children[i].get(), scene);
    }
}

Entity::Entity(Engine* engine, std::string name) : EngineObject(engine), name(name) {
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
            const auto &parent = _parent;
            if ((parent != nullptr && parent->_isActiveInHierarchy)
                || (_isRoot && _scene->_isActiveInEngine)) {
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

Entity* Entity::parent() {
    return _parent;
}

void Entity::setParent(Entity* entity) {
    if (entity != _parent) {
        const auto oldParent = _removeFromParent();
        auto newParent = _parent = entity;
        if (newParent) {
            newParent->_children.push_back(EntityPtr(this));
            const auto parentScene = newParent->_scene;
            if (_scene != parentScene) {
                Entity::_traverseSetOwnerScene(this, parentScene);
            }
            
            if (newParent->_isActiveInHierarchy) {
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
                Entity::_traverseSetOwnerScene(this, nullptr);
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

Scene* Entity::scene() {
    return _scene;
}

void Entity::addChild(EntityPtr child) {
    child->setParent(this);
}

void Entity::removeChild(EntityPtr child) {
    child->setParent(nullptr);
}

EntityPtr Entity::getChild(int index) {
    return _children[index];
}

EntityPtr Entity::findByName(const std::string &name) {
    const auto &children = _children;
    const auto child = Entity::_findChildByName(this, name);
    if (child) return child;
    for (size_t i = 0; i < children.size(); i++) {
        const auto &child = children[i];
        const auto grandson = child->findByName(name);
        if (grandson) {
            return grandson;
        }
    }
    return nullptr;
}

EntityPtr Entity::createChild(const std::string &name) {
    auto child = std::make_shared<Entity>(engine(), name);
    child->layer = layer;
    child->setParent(this);
    return child;
}

void Entity::clearChildren() {
    auto &children = _children;
    for (size_t i = 0; i < children.size(); i++) {
        const auto &child = children[i];
        child->_parent = nullptr;
        if (child->_isActiveInHierarchy) {
            child->_processInActive();
        }
        Entity::_traverseSetOwnerScene(child.get(), nullptr); // Must after child._processInActive().
    }
    children.clear();
}

EntityPtr Entity::clone() {
    auto cloneEntity = std::make_shared<Entity>(_engine, name);
    
    cloneEntity->_isActive = _isActive;
    cloneEntity->transform->setLocalMatrix(transform->localMatrix());
    
    const auto &children = _children;
    for (size_t i = 0, len = _children.size(); i < len; i++) {
        const auto &child = children[i];
        cloneEntity->addChild(child->clone());
    }
    
    const auto &components = _components;
    for (size_t i = 0, n = components.size(); i < n; i++) {
        const auto &sourceComp = components[i];
        if (!(dynamic_cast<Transform *>(sourceComp.get()))) {
            // TODO
        }
    }
    
    return cloneEntity;
}

void Entity::destroy() {
    auto &abilityArray = _components;
    for (size_t i = 0; i < abilityArray.size(); i++) {
        abilityArray[i]->destroy();
    }
    _components.clear();
    
    const auto &children = _children;
    for (size_t i = 0; i < children.size(); i++) {
        children[i]->destroy();
    }
    _children.clear();
    
    if (_parent != nullptr) {
        auto &parentChildren = _parent->_children;
        parentChildren.erase(std::remove_if(parentChildren.begin(), parentChildren.end(),
                                             [&](const auto& child) {
            return child.get() == this;
        }), parentChildren.end());
    }
    _parent = nullptr;
}

void Entity::_removeComponent(Component *component) {
    // ComponentsDependencies._removeCheck(this, component.constructor as any);
    auto &components = _components;
    components.erase(std::remove_if(components.begin(),
                                    components.end(), [&](const std::unique_ptr<Component> &x) {
        return x.get() == component;
    }), components.end());
}

void Entity::_addScript(Script *script) {
    script->_entityCacheIndex = _scripts.size();
    _scripts.push_back(script);
}

void Entity::_removeScript(Script *script) {
    std::remove(_scripts.begin(), _scripts.end(), script);
    script->_entityCacheIndex = -1;
}

Entity* Entity::_removeFromParent() {
    const auto &oldParent = _parent;
    if (oldParent != nullptr) {
        auto &oldParentChildren = oldParent->_children;
        oldParentChildren.erase(std::remove_if(oldParentChildren.begin(), oldParentChildren.end(),
                                               [&](const auto& child){
            return child.get() == this;
        }), oldParentChildren.end());
        _parent = nullptr;
    }
    return oldParent;
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

void Entity::_setActiveComponents(bool isActive) {
    auto &activeChangedComponents = _activeChangedComponents;
    for (size_t i = 0, length = activeChangedComponents.size(); i < length; ++i) {
        activeChangedComponents[i]->_setActive(isActive);
    }
    _engine->_componentsManager.putActiveChangedTempList(activeChangedComponents);
    _activeChangedComponents.clear();
}

void Entity::_setActiveInHierarchy(std::vector<Component *> &activeChangedComponents) {
    _isActiveInHierarchy = true;
    auto &components = _components;
    for (size_t i = 0; i < components.size(); i++) {
        activeChangedComponents.push_back(components[i].get());
    }
    const auto &children = _children;
    for (size_t i = 0; i < children.size(); i++) {
        const auto &child = children[i];
        if (child->isActive()) {
            child->_setActiveInHierarchy(activeChangedComponents);
        }
    }
}

void Entity::_setInActiveInHierarchy(std::vector<Component *> &activeChangedComponents) {
    _isActiveInHierarchy = false;
    auto &components = _components;
    for (size_t i = 0; i < components.size(); i++) {
        activeChangedComponents.push_back(components[i].get());
    }
    auto &children = _children;
    for (size_t i = 0; i < children.size(); i++) {
        const auto &child = children[i];
        if (child->isActive()) {
            child->_setInActiveInHierarchy(activeChangedComponents);
        }
    }
}

void Entity::_setTransformDirty() {
    if (transform) {
        transform->_parentChange();
    } else {
        for (size_t i = 0, len = _children.size(); i < len; i++) {
            _children[i]->_setTransformDirty();
        }
    }
}

std::vector<Script*> Entity::scripts() {
    return _scripts;
}


}
