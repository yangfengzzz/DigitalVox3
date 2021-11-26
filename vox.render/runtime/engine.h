//
//  engine.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef engine_hpp
#define engine_hpp

#include <memory>
#include "components_manager.h"
#include "scene_manager.h"

namespace vox {
class Engine {
public:
    ComponentsManager _componentsManager;
    
    /**
     * Get the scene manager.
     */
    SceneManager sceneManager() {
        return _sceneManager;
    }
    
private:
    SceneManager _sceneManager = SceneManager(this);
    int _vSyncCount = 1;
    float _targetFrameRate = 60;
    //    private _time: Time = new Time();
    bool _isPaused = true;
    int _requestId;
    int _timeoutId;
    int _vSyncCounter = 1;
    float _targetFrameInterval = 1000 / 60;
};

using EnginePtr = std::shared_ptr<Engine>;

}

#endif /* engine_hpp */
