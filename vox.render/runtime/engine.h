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

namespace vox {
class Engine {
public:
    ComponentsManager _componentsManager;
};

using EnginePtr = std::shared_ptr<Engine>;

}

#endif /* engine_hpp */
