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
    void addOnStartScript(Script* script);
    
    void removeOnStartScript(Script* script);
    
    void addOnUpdateScript(Script* script);
    
    void removeOnUpdateScript(Script* script);
    
    void addOnLateUpdateScript(Script* script);

    void removeOnLateUpdateScript(Script* script);
    
public:
    void callScriptOnStart();
    
    void callScriptOnUpdate(float deltaTime);
    
    void callScriptOnLateUpdate(float deltaTime);
    
public:
    std::vector<Component *> getActiveChangedTempList();
    
    void putActiveChangedTempList(std::vector<Component *> &componentContainer);
    
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
