//
//  blend_mode.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef blend_mode_h
#define blend_mode_h

/**
 * Alpha blend mode.
 */
struct BlendMode {
    enum Enum {
        /** SRC ALPHA * SRC + (1 - SRC ALPHA) * DEST */
        Normal,
        /** SRC ALPHA * SRC + ONE * DEST */
        Additive
    };
};


#endif /* blend_mode_h */
