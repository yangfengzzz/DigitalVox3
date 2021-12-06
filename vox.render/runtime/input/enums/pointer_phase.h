//
//  pointer_phase.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef pointer_phase_h
#define pointer_phase_h

namespace vox {
namespace input {
/**
 *  The current phase of the pointer.
 */
enum PointerPhase {
    /** A Pointer pressed on the screen. */
    Down,
    /** A pointer moved on the screen. */
    Move,
    /** A pointer was lifted from the screen. */
    Up,
    /** The system cancelled tracking for the pointer. */
    Leave
};

}
}

#endif /* pointer_phase_h */
