//
//  sky.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/12/17.
//

#ifndef sky_h
#define sky_h

#include "../material/material.h"
#include "../graphics/mesh.h"
#include "maths/vec_float.h"

namespace vox {
/**
 * Sky.
 */
struct Sky {
    /** Material of the sky. */
    MaterialPtr material{nullptr};
    /** Mesh of the sky. */
    MeshPtr mesh{nullptr};
};

}

#endif /* Sky_h */
