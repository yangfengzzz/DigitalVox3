//
//  components_manager.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef components_manager_hpp
#define components_manager_hpp

#include <vector>
#include "component.h"

namespace vox {
class Script;

/**
 * The manager of the components.
 */
class ComponentsManager {
public:
    std::vector<Component *> getActiveChangedTempList() {
        return _componentsContainerPool.size() ? *(_componentsContainerPool.end() - 1) : std::vector<Component *>{};
    }
    
    void putActiveChangedTempList(std::vector<Component *> &componentContainer) {
        componentContainer.clear();
        _componentsContainerPool.push_back(componentContainer);
    }
    
private:
    // Script
    std::vector<Script *> _onStartScripts;
    std::vector<Script *> _onUpdateScripts;
    std::vector<Script *> _onLateUpdateScripts;
    std::vector<Script *> _destroyComponents;
    
    // Delay dispose active/inActive Pool
    std::vector<std::vector<Component *>> _componentsContainerPool;
};

}

#endif /* components_manager_hpp */
