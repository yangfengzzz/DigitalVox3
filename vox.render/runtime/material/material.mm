//
//  material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "material.h"

namespace vox {
Material::Material(EnginePtr engine, Shader* shader):EngineObject(engine), shader(shader) {
}

}
