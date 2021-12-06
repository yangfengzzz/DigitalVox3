//
//  pointer_manager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "pointer_manager.h"
#include "../../engine.h"
#include "../../canvas.h"

namespace vox {
namespace input {
PointerManager::PointerManager(Engine* engine):
_engine(engine),
_canvas(engine->canvas()){
    auto pointerEventCallback = [&](GLFWwindow* window, int button, int action, int mods) {
        _nativeEvents.push_back(PointerEvent());
    };
    Canvas::mouse_button_callbacks.push_back(pointerEventCallback);
}

void PointerManager::_update() {
    if (_needOverallPointers) {
        _overallPointers();
    }
    if (_nativeEvents.size() > 0) {
        _handlePointerEvent(_nativeEvents);
    }
    auto rayCastEntity = _pointerRayCast();
    if (_keyEventCount > 0) {
        for (size_t i = 0; i < _keyEventCount; i++) {
            switch (_keyEventList[i]) {
                case PointerKeyEvent::Down:
                    _firePointerDown(rayCastEntity);
                    break;
                case PointerKeyEvent::Up:
                    _firePointerUpAndClick(rayCastEntity);
                    break;
            }
        }
        _firePointerExitAndEnter(rayCastEntity);
        _keyEventList[_keyEventCount - 1] == PointerKeyEvent::Leave && (_currentPressedEntity = nullptr);
        _keyEventCount = 0;
    } else {
        _firePointerDrag();
        _firePointerExitAndEnter(rayCastEntity);
    }
}

void PointerManager::_destroy() {
    
}

void PointerManager::_overallPointers() {
    size_t deleteCount = 0;
    auto totalCount = _pointers.size();
    for (size_t i = 0; i < totalCount; i++) {
        if (_pointers[i].phase == PointerPhase::Leave) {
            deleteCount++;
        } else {
            if (deleteCount > 0) {
                _pointers[i - deleteCount] = _pointers[i];
            }
        }
    }
    _pointers.erase(_pointers.begin() + totalCount - deleteCount, _pointers.end());
    _needOverallPointers = false;
}

ssize_t PointerManager::_getIndexByPointerID(size_t pointerId) {
    for (size_t i = 0; i < _pointers.size(); i++) {
        if (_pointers[i]._uniqueID == pointerId) {
            return i;
        }
    }
    return -1;
}

void PointerManager::_addPointer(size_t pointerId, float x, float y, PointerPhase::Enum phase) {
    size_t lastCount = _pointers.size();
    if (lastCount == 0 || _multiPointerEnabled) {
        // Get Pointer smallest index.
        size_t i = 0;
        for (; i < lastCount; i++) {
            if (_pointers[i].id > i) {
                break;
            }
        }
        auto& pointer = _pointerPool[i];
        if (pointer.id == -1) {
            pointer.id = i;
        }
        pointer._uniqueID = pointerId;
        pointer._needUpdate = true;
        pointer.position = math::Float2(x, y);
        pointer.phase = phase;
        _pointers.insert(_pointers.begin() + i, pointer);
    }
}

void PointerManager::_removePointer(size_t pointerIndex) {
    _pointers[pointerIndex].phase = PointerPhase::Leave;
}

void PointerManager::_updatePointer(size_t pointerId, float x, float y, PointerPhase::Enum phase) {
    auto& updatedPointer = _pointers[pointerId];
    updatedPointer.position = math::Float2(x, y);
    updatedPointer._needUpdate = true;
    updatedPointer.phase = phase;
}

void PointerManager::_handlePointerEvent(std::vector<PointerEvent>& nativeEvents) {
    
}

Entity* PointerManager::_pointerRayCast() {
    return nullptr;
}

void PointerManager::_firePointerDrag() {
    if (_currentPressedEntity) {
        const auto& scripts = _currentPressedEntity->scripts();
        for (size_t i = 0; i < scripts.size(); i++) {
            scripts[i]->onPointerDrag();
        }
    }
}

void PointerManager::_firePointerExitAndEnter(Entity* rayCastEntity) {
    if (_currentEnteredEntity != rayCastEntity) {
        if (_currentEnteredEntity) {
            const auto& scripts = _currentEnteredEntity->scripts();
            for (size_t i = 0; i < scripts.size(); i++) {
                scripts[i]->onPointerExit();
            }
        }
        if (rayCastEntity) {
            const auto& scripts = rayCastEntity->scripts();
            for (size_t i = 0; i < scripts.size(); i++) {
                scripts[i]->onPointerEnter();
            }
        }
        _currentEnteredEntity = rayCastEntity;
    }
}

void PointerManager::_firePointerDown(Entity* rayCastEntity) {
    if (rayCastEntity) {
        const auto& scripts = rayCastEntity->scripts();
        for (size_t i = 0; i < scripts.size(); i++) {
            scripts[i]->onPointerDown();
        }
    }
    _currentPressedEntity = rayCastEntity;
}

void PointerManager::_firePointerUpAndClick(Entity* rayCastEntity) {
    if (_currentPressedEntity) {
        auto sameTarget = _currentPressedEntity == rayCastEntity;
        const auto& scripts = _currentPressedEntity->scripts();
        for (size_t i = 0; i < scripts.size(); i++) {
            const auto& script = scripts[i];
            if (sameTarget) {
                script->onPointerClick();
            }
            script->onPointerUp();
        }
        _currentPressedEntity = nullptr;
    }
}

}
}
