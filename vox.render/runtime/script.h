//
//  script.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef script_hpp
#define script_hpp

#include "component.h"

namespace ozz {
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
    
private:
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
