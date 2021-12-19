//
//  macro_name.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef macro_name_h
#define macro_name_h

// int have no verb, other will use:
// HAS_ : Resouce
// OMMIT_ : Omit Resouce
// NEED_ : Shader Operation
// IS_ : Shader control flow
// _COUNT: type int constant
enum MacroName {
    HAS_UV = 0,
    HAS_NORMAL = 1,
    HAS_TANGENT = 2,
    HAS_VERTEXCOLOR = 3,
    
    // Blend Shape
    HAS_BLENDSHAPE = 4,
    HAS_BLENDSHAPE_NORMAL = 5,
    HAS_BLENDSHAPE_TANGENT = 6,
    
    // Skin
    HAS_SKIN = 7,
    HAS_JOINT_TEXTURE = 8,
    JOINTS_COUNT = 9,
    
    // Material
    NEED_ALPHA_CUTOFF = 10,
    NEED_WORLDPOS = 11,
    NEED_TILINGOFFSET = 12,
    HAS_DIFFUSE_TEXTURE = 13,
    HAS_SPECULAR_TEXTURE = 14,
    HAS_EMISSIVE_TEXTURE = 15,
    HAS_NORMAL_TEXTURE = 16,
    OMIT_NORMAL = 17,
    HAS_BASE_TEXTURE = 18,
    HAS_BASE_COLORMAP = 19,
    HAS_EMISSIVEMAP = 20,
    HAS_OCCLUSIONMAP = 21,
    HAS_SPECULARMAP = 22,
    HAS_GLOSSINESSMAP = 23,
    HAS_METALROUGHNESSMAP = 24,
    IS_METALLIC_WORKFLOW = 26,
    
    // Light
    DIRECT_LIGHT_COUNT = 27,
    POINT_LIGHT_COUNT = 28,
    SPOT_LIGHT_COUNT = 29,
    
    // Enviroment
    HAS_SH = 30,
    HAS_SPECULAR_ENV = 31,
    HAS_DIFFUSE_ENV = 32,
    
    // Particle Render
    HAS_PARTICLE_TEXTURE = 33,
    NEED_ROTATE_TO_VELOCITY = 34,
    NEED_USE_ORIGIN_COLOR = 35,
    NEED_SCALE_BY_LIFE_TIME = 36,
    NEED_FADE_IN = 37,
    NEED_FADE_OUT = 38,
    IS_2D = 39,
    
    // Shadow
    NEED_GENERATE_SHADOW_MAP = 40,
    SHADOW_MAP_COUNT = 41,
    
    TOTAL_COUNT = 42,
};

#endif /* macro_name_h */
