//
//  shadow_map_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#include "shadow_map_material.h"

namespace vox {
ShadowMapMaterial::ShadowMapMaterial(Engine* engine):
Material(engine, Shader::find("shadow-map")){
    shaderData.enableMacro(NEED_GENERATE_SHADOW_MAP);
}

}
