//
//  script.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef script_hpp
#define script_hpp

#include "component.h"

namespace vox {
/**
 * Script class, used for logic writing.
 */
class Script : public Component {
    /**
     * Called when be enabled first time, only once.
     */
    virtual void onAwake() {}
    
    /**
     * Called when be enabled.
     */
    virtual void onEnable() {}
    
    /**
     * Called before the frame-level loop start for the first time, only once.
     */
    virtual void onStart() {}
    
    /**
     * The main loop, called frame by frame.
     * @param deltaTime - The deltaTime when the script update.
     */
    virtual void onUpdate(float deltaTime) {}
    
    /**
     * Called after the onUpdate finished, called frame by frame.
     * @param deltaTime - The deltaTime when the script update.
     */
    virtual void onLateUpdate(float deltaTime) {}
    
    /**
     * Called before camera rendering, called per camera.
     * @param camera - Current camera.
     */
    virtual void onBeginRender(Camera* camera) {}
    
    /**
     * Called after camera rendering, called per camera.
     * @param camera - Current camera.
     */
    virtual void onEndRender(Camera* camera) {}
    
    /**
     * Called when the pointer is down while over the ColliderShape.
     */
    virtual void onPointerDown() {}
    
    /**
     * Called when the pointer is up while over the ColliderShape.
     */
    virtual void onPointerUp() {}
    
    /**
     * Called when the pointer is down and up with the same collider.
     */
    virtual void onPointerClick() {}
    
    /**
     * Called when the pointer is enters the ColliderShape.
     */
    virtual void onPointerEnter() {}
    
    /**
     * Called when the pointer is no longer over the ColliderShape.
     */
    virtual void onPointerExit() {}
    
    /**
     * Called when the pointer is down while over the ColliderShape and is still holding down.
     * @remarks onPointerDrag is called every frame while the pointer is down.
     */
    virtual void onPointerDrag() {}
    
    /**
     * Called when be disabled.
     */
    virtual void onDisable() {}
    
    /**
     * Called at the end of the destroyed frame.
     */
    virtual void onDestroy() {}
    
    
private:
    friend class Entity;
    friend class ComponentsManager;
    
    void _onAwake() override;
    
    void _onEnable() override;
    
    void _onDisable() override;
    
    void _onDestroy() override;
    
    bool _started = false;
    ssize_t _onStartIndex = -1;
    ssize_t _onUpdateIndex = -1;
    ssize_t _onLateUpdateIndex = -1;
    ssize_t _onPreRenderIndex = -1;
    ssize_t _onPostRenderIndex = -1;
    ssize_t _entityCacheIndex = -1;
};

}

#endif /* script_hpp */
