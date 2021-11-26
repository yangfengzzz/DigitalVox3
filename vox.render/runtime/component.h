//
//  component.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef component_hpp
#define component_hpp

#include "engine_object.h"

namespace ozz {
class Entity;
/**
 * The base class of the components.
 */
class Component :public EngineObject {
public:
    Entity* _entity;
    bool _destroyed = false;
    
private:
    bool _enabled = true;
    bool _awoken = false;
};

}
#endif /* component_hpp */
