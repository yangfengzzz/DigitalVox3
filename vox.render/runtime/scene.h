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
/**
 * Scene.
 */
class Scene : public EngineObject {
public:
    /** Scene name. */
    std::string name;
    
private:
    friend class Entity;
    
    bool _isActiveInEngine = false;
    bool _destroyed = false;
    std::vector<EntityPtr> _rootEntities;
};

}

#endif /* scene_hpp */
