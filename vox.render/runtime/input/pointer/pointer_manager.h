//
//  pointer_manager.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef pointer_manager_hpp
#define pointer_manager_hpp

#include "pointer.h"
#include "../../vox_type.h"
#include <vector>
#include <array>

namespace vox {
namespace input {
struct PointerEvent{};

/**
 * Pointer Manager.
 */
class PointerManager {
public:
    /**
     * Create a PointerManager.
     * @param engine - The current engine instance
     */
    PointerManager(Engine* engine);
    
private:
    void _update();
    
    void _destroy();
    
    void _overallPointers();
    
    ssize_t _getIndexByPointerID(size_t pointerId);
    
    void _addPointer(size_t pointerId, float x, float y, PointerPhase phase);
    
    void _removePointer(size_t pointerIndex);
    
    void _updatePointer(size_t pointerId, float x, float y, PointerPhase phase);
    
    void _handlePointerEvent(std::vector<PointerEvent>& nativeEvents);
    
    Entity* _pointerRayCast();
    
    void _firePointerDrag();
    
    void _firePointerExitAndEnter(Entity* rayCastEntity);
    
    void _firePointerDown(Entity* rayCastEntity);
    
    void _firePointerUpAndClick(Entity* rayCastEntity);
    
    
private:
    enum PointerKeyEvent {
        Down,
        Up,
        Leave
    };
    
    std::vector<Pointer> _pointers;
    bool _multiPointerEnabled = true;
    
    Engine* _engine;
    Canvas* _canvas;
    std::vector<PointerEvent> _nativeEvents;
    std::array<Pointer, 11> _pointerPool{};
    std::vector<size_t> _keyEventList;
    size_t _keyEventCount;
    bool _needOverallPointers = false;
    math::Float2 _currentPosition;
    Entity* _currentPressedEntity;
    Entity* _currentEnteredEntity;
};

}
}

#endif /* pointer_manager_hpp */
