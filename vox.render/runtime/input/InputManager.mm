//
//  InputManager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "InputManager.h"
#include "../engine.h"

namespace vox {
namespace input {
InputManager::InputManager(Engine *engine) :
_pointerManager(PointerManager(engine)) {
}

std::vector<Pointer> &InputManager::pointers() {
    return _pointerManager._pointers;
}

bool InputManager::multiPointerEnabled() {
    return _pointerManager._multiPointerEnabled;
}

void InputManager::setMultiPointerEnabled(bool enabled) {
    _pointerManager._multiPointerEnabled = enabled;
}

void InputManager::_update() {
    _pointerManager._update();
}

void InputManager::_destroy() {
    _pointerManager._destroy();
}

}
}
