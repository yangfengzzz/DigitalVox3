//
//  component.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef component_hpp
#define component_hpp

#include "engine_object.h"

namespace vox {
/**
 * The base class of the components.
 */
class Component : public EngineObject {
public:
    explicit Component(Entity *entity);
    
    /**
     * Indicates whether the component is enabled.
     */
    bool enabled();
    
    void setEnabled(bool value);
    
    /**
     * Indicates whether the component is destroyed.
     */
    bool destroyed();
    
    /**
     * The entity which the component belongs to.
     */
    Entity *entity() const;
    
    /**
     * The scene which the component's entity belongs to.
     */
    Scene *scene();
    
    /**
     * Destroy this instance.
     */
    void destroy();
    
public:
    virtual void _onAwake() {
    }
    
    virtual void _onEnable() {
    }
    
    virtual void _onDisable() {
    }
    
    virtual void _onDestroy() {
    }
    
    virtual void _onActive() {
    }
    
    virtual void _onInActive() {
    }
    
protected:
    friend class Entity;
    
    void _setActive(bool value);
    
    Entity *_entity;
    bool _destroyed = false;
    
private:
    bool _enabled = true;
    bool _awoken = false;
};

}
#endif /* component_hpp */
