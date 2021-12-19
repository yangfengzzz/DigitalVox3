//
//  shadow_map_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#ifndef shadow_map_material_hpp
#define shadow_map_material_hpp

#include "../material/material.h"

namespace vox {
/**
 * Shadow Map material.
 */
class ShadowMapMaterial :public Material {
public:
    ShadowMapMaterial(Engine* engine);
};

}

#endif /* shadow_map_material_hpp */
