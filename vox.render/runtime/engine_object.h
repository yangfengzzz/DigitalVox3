//
//  engine_object.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef engine_object_hpp
#define engine_object_hpp

#include "engine.h"

namespace ozz {
class EngineObject {
public:
    /** Engine unique id. */
    int getInstanceId();
    
    EnginePtr getEngine();
    
    EngineObject(EnginePtr engine);
    
protected:
    /** Engine to which the object belongs. */
    EnginePtr _engine;
    
private:
    static int _instanceIdCounter;
};

}

#endif /* engine_object_hpp */
