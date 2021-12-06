//
//  pointer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef pointer_hpp
#define pointer_hpp

#include "maths/vec_float.h"
#include "../enums/pointer_phase.h"

namespace vox {
namespace input {
/**
 * Pointer.
 */
class Pointer {
public:
    /**
     * Unique id.
     * @remark Start from 0.
     */
    size_t id;
    /** The phase of pointer. */
    PointerPhase::Enum phase = PointerPhase::Enum::Leave;
    /** The position of the pointer in screen space pixel coordinates. */
    math::Float2 position;
    
private:
    friend class PointerManager;
    
    size_t _uniqueID;
    bool _needUpdate = true;
    
    Pointer(size_t id = -1);
};

}
}

#endif /* pointer_hpp */
