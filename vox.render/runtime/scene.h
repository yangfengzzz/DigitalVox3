//
//  scene.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef scene_hpp
#define scene_hpp

#include <string>
#include "engine_object.h"
#include "entity.h"

namespace vox {
class Camera;

/**
 * Scene.
 */
class Scene : public EngineObject {
public:
    /** Scene name. */
    std::string name;
    
    /**
     * Create scene.
     * @param engine - Engine
     * @param name - Name
     */
    Scene(Engine* engine, std::string name = "");
    
    /**
     * Count of root entities.
     */
    size_t rootEntitiesCount();
    
    /**
     * Root entity collection.
     */
    const std::vector<EntityPtr> rootEntities();
    
    /**
     * Whether it's destroyed.
     */
    bool destroyed();
    
    /**
     * Create root entity.
     * @param name - Entity name
     * @returns Entity
     */
    EntityPtr createRootEntity(std::string name = "");
    
    /**
     * Append an entity.
     * @param entity - The root entity to add
     */
    void addRootEntity(EntityPtr entity);
    
    /**
     * Remove an entity.
     * @param entity - The root entity to remove
     */
    void removeRootEntity(EntityPtr entity);
    
    /**
     * Get root entity from index.
     * @param index - Index
     * @returns Entity
     */
    EntityPtr getRootEntity(size_t index = 0);
    
    /**
     * Find entity globally by name.
     * @param name - Entity name
     * @returns Entity
     */
    EntityPtr findEntityByName(const std::string& name);
    
    /**
     * Destroy this scene.
     */
    void destroy();
    
private:
    friend class Engine;
    friend class Entity;
    friend class Camera;
    
    void _attachRenderCamera(Camera* camera);
    
    void _detachRenderCamera(Camera* camera);
    
    void _processActive(bool active);
    
    void _removeEntity(EntityPtr entity);

    std::vector<Camera*> _activeCameras;
    bool _isActiveInEngine = false;
    bool _destroyed = false;
    std::vector<EntityPtr> _rootEntities;
};

}

#endif /* scene_hpp */
