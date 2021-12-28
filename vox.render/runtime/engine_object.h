//
//  engine_object.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef engine_object_hpp
#define engine_object_hpp

#include "vox_type.h"

namespace vox {
class EngineObject {
public:
    EngineObject(Engine *engine);
    
    /** Engine unique id. */
    int instanceId();
    
    Engine *engine();
    
protected:
    /** Engine to which the object belongs. */
    Engine *_engine;
    
private:
    static int _instanceIdCounter;
};

}

#endif /* engine_object_hpp */
