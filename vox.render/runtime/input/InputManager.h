//
//  InputManager.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef InputManager_hpp
#define InputManager_hpp

#include "pointer/pointer_manager.h"

namespace vox {
namespace input {
/**
 * InputManager manages device input such as mouse, touch, keyboard, etc.
 */
class InputManager {
public:
    InputManager(Engine* engine);
    
    /**
     * Pointer List.
     */
    std::vector<Pointer>& pointers();

    /**
     *  Whether to handle multi-pointer.
     */
    bool multiPointerEnabled();

    void setMultiPointerEnabled(bool enabled);
    
private:
    void _update();

    void _destroy();
    
    PointerManager _pointerManager;
};

}
}

#endif /* InputManager_hpp */
