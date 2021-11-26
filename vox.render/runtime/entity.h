//
//  entity.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef entity_hpp
#define entity_hpp

#include <string>

#include "engine_object.h"
#include "layer.h"
#include "transform.h"
#include "script.h"

namespace vox {
class Scene;
using ScenePtr = std::shared_ptr<Scene>;
class Entity;
using EntityPtr = std::shared_ptr<Entity>;

/**
 * Entity, be used as components container.
 */
class Entity final : public EngineObject {
public:
    /** The name of entity. */
    std::string name;
    /** The layer the entity belongs to. */
    Layer layer = Layer::Layer0;
    /** Transform component. */
    const Transform* transform;
    
    /**
     * Create a entity.
     * @param engine - The engine the entity belongs to.
     */
    Entity(EnginePtr engine, std::string name = "");
    
    /**
     * Whether to activate locally.
     */
    bool isActive() {
        return _isActive;
    }
    
    void setIsActive(bool value);
    
    /**
     * Whether it is active in the hierarchy.
     */
    bool isActiveInHierarchy() {
        return _isActiveInHierarchy;
    }
    
    /**
     * The parent entity.
     */
    EntityPtr parent() {
        return _parent.lock();
    }
    
    void setParent(EntityPtr entity) {
    }
    
    
    /**
     * Number of the children entities
     */
    size_t childCount() {
        return _children.size();
    }
    
    /**
     * The scene the entity belongs to.
     */
    ScenePtr scene() {
        return _scene.lock();
    }
    
    /**
     * The children entities
     */
    const std::vector<EntityPtr> children() const {
        return _children;
    }
    
    /**
     * Add component based on the component type.
     * @returns    The component which has been added.
     */
    template<typename T>
    T* addComponent() {
        // ComponentsDependencies._addCheck(this, type);
        const auto component = std::make_unique<T>(this);
        T* componentPtr = component.get();
        _components.emplace_back(std::move(component));
        if (_isActiveInHierarchy) {
            componentPtr->_setActive(true);
        }
        return componentPtr;
    }
    
    /**
     * Get component which match the type.
     * @returns    The first component which match type.
     */
    template<typename T>
    T* getComponent();
    
    /**
     * Get components which match the type.
     * @returns    The components which match type.
     */
    template<typename T>
    std::vector<T*> getComponents();
    
    /**
     * Get the components which match the type of the entity and it's children.
     * @returns    The components collection which match the type.
     */
    template<typename T>
    std::vector<T*> getComponentsIncludeChildren();
    
    /**
     * Add child entity.
     * @param child - The child entity which want to be added.
     */
    void addChild(EntityPtr child);
    
    /**
     * Remove child entity.
     * @param child - The child entity which want to be removed.
     */
    void removeChild(EntityPtr child);
    
    /**
     * Find child entity by index.
     * @param index - The index of the child entity.
     * @returns    The component which be found.
     */
    EntityPtr getChild(int index);
    
    /**
     * Find child entity by name.
     * @param name - The name of the entity which want to be found.
     * @returns The component which be found.
     */
    EntityPtr findByName(const std::string& name);
    
    /**
     * Find the entity by path.
     * @param path - The path fo the entity eg: /entity.
     * @returns The component which be found.
     */
    EntityPtr findByPath(const std::string& path);
    
    /**
     * Create child entity.
     * @param name - The child entity's name.
     * @returns The child entity.
     */
    EntityPtr createChild(const std::string& name = "");
    
    /**
     * Clear children entities.
     */
    void clearChildren();
    
    /**
     * Clone
     * @returns Cloned entity.
     */
    EntityPtr clone();
    
    /**
     * Destroy self.
     */
    void destroy();
    
private:
    void _removeComponent(Component* component);
    
    void _addScript(Script* script);
    
    void _removeScript(Script* script);
    
    EntityPtr _removeFromParent();
    
    void _processActive();
    
    void _processInActive();
    
    template<typename T>
    void _getComponentsInChildren(std::vector<T*>& results);
    
    void _setActiveComponents(bool isActive);
    
    void _setActiveInHierarchy(std::vector<Component*>& activeChangedComponents);
    
    void _setInActiveInHierarchy(std::vector<Component*>& activeChangedComponents);
    
    void _setTransformDirty();
    
    static EntityPtr _findChildByName(EntityPtr root, const std::string& name) {
        const auto& children = root->_children;
        for (size_t i = children.size() - 1; i >= 0; i--) {
            const auto& child = children[i];
            if (child->name == name) {
                return child;
            }
        }
        return nullptr;
    }
    
    static void _traverseSetOwnerScene(EntityPtr entity, std::weak_ptr<Scene> scene) {
        entity->_scene = scene;
        const auto& children = entity->_children;
        for (size_t i = entity->_children.size() - 1; i >= 0; i--) {
            _traverseSetOwnerScene(children[i], scene);
        }
    }
    
    bool _isActiveInHierarchy = false;
    std::vector<std::unique_ptr<Component>> _components;
    std::vector<Script*> _scripts;
    std::vector<EntityPtr> _children;
    std::weak_ptr<Scene> _scene;
    bool _isRoot = false;
    bool _isActive = true;
    
    std::weak_ptr<Entity> _parent;
    std::vector<Component*> _activeChangedComponents;
};

}

#endif /* entity_hpp */
