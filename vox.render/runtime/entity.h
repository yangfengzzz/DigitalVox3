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

namespace ozz {
/**
 * Entity, be used as components container.
 */
class Entity : public EngineObject {
public:
    /** The name of entity. */
    std::string name;
    /** The layer the entity belongs to. */
    Layer layer = Layer::Layer0;
    /** Transform component. */
    Transform transform;
};

}

#endif /* entity_hpp */
