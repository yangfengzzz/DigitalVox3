//
//  textureCube_face.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef textureCube_face_h
#define textureCube_face_h

/**
 * Define the face of the cube texture.
 */
struct TextureCubeFace {
    enum Enum {
        /** Positive X face for a cube-mapped texture. */
        PositiveX = 0,
        /** Negative X face for a cube-mapped texture. */
        NegativeX = 1,
        /** Positive Y face for a cube-mapped texture. */
        PositiveY = 2,
        /** Negative Y face for a cube-mapped texture. */
        NegativeY = 3,
        /** Positive Z face for a cube-mapped texture. */
        PositiveZ = 4,
        /** Negative Z face for a cube-mapped texture. */
        NegativeZ = 5
    };
};

#endif /* textureCube_face_h */
