//
//  pointer_manager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "pointer_manager.h"

namespace vox {
namespace input {
PointerManager::PointerManager(Engine* engine) {}

void PointerManager::_update() {
    
}

void PointerManager::_destroy() {
    
}

void PointerManager::_overallPointers() {
    
}

ssize_t PointerManager::_getIndexByPointerID(size_t pointerId) {
    for (size_t i = 0; i < _pointers.size(); i++) {
        if (_pointers[i]._uniqueID == pointerId) {
            return i;
        }
    }
    return -1;
}

void PointerManager::_addPointer(size_t pointerId, float x, float y, PointerPhase phase) {
    
}

void PointerManager::_removePointer(size_t pointerIndex) {
    
}

void PointerManager::_updatePointer(size_t pointerId, float x, float y, PointerPhase phase) {
    
}

void PointerManager::_handlePointerEvent(std::vector<PointerEvent>& nativeEvents) {
    
}

Entity* PointerManager::_pointerRayCast() {
    return nullptr;
}

void PointerManager::_firePointerDrag() {
    
}

void PointerManager::_firePointerExitAndEnter(Entity* rayCastEntity) {
    
}

void PointerManager::_firePointerDown(Entity* rayCastEntity) {
    
}

void PointerManager::_firePointerUpAndClick(Entity* rayCastEntity) {
    
}

}
}
