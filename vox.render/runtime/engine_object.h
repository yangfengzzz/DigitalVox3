//
//  engine_object.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef engine_object_hpp
#define engine_object_hpp

#include <memory>

namespace vox {
class Engine;

using EnginePtr = std::shared_ptr<Engine>;

class EngineObject {
public:
    EngineObject(EnginePtr engine);
    
    /** Engine unique id. */
    int instanceId();
    
    EnginePtr engine();
    
protected:
    /** Engine to which the object belongs. */
    EnginePtr _engine;
    
private:
    static int _instanceIdCounter;
};

}

#endif /* engine_object_hpp */
