//
//  camera_clear_flags.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef camera_clear_flags_h
#define camera_clear_flags_h

/**
 * Camera clear flags enumeration.
 */
enum CameraClearFlags {
    /* Clear depth and color from background. */
    DepthColor,
    /* Clear depth only. */
    Depth,
    /* Do nothing. */
    None
};

#endif /* camera_clear_flags_h */
