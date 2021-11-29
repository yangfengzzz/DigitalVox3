//
//  shader_pool.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "shader_pool.h"
#include "shader.h"

namespace vox {
void ShaderPool::initialization() {
    Shader::create("blinn-phong", "vertex_blinn_phong", "fragment_blinn_phong");
    Shader::create("pbr", "vertex_blinn_phong", "fragment_pbr");
    Shader::create("pbr-specular", "vertex_blinn_phong", "fragment_pbr");
    Shader::create("unlit", "vertex_unlit", "fragment_unlit");
    Shader::create("shadow-map", "vertex_shadow_map", "fragment_shadow_map");
    Shader::create("shadow", "vertex_shadow_map", "fragment_shadow");
    Shader::create("skybox", "vertex_skybox", "fragment_skybox");
    Shader::create("particle-shader", "vertex_particle", "fragment_particle");
    Shader::create("background-texture", "vertex_background_texture", "fragment_background_texture");
    
    Shader::create("simple", "vertex_simple", "fragment_simple");
}

}
