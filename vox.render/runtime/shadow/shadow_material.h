//
//  shadow_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#ifndef shadow_material_hpp
#define shadow_material_hpp

#include "../material/material.h"

namespace vox {
/**
 * Shadow material.
 */
class ShadowMaterial :public Material {
public:
    ShadowMaterial(Engine* engine);
};

}

#endif /* shadow_material_hpp */
