//
//  shader_macro_collection.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "shader_macro_collection.h"
#include "maths/math_ex.h"

namespace vox {
std::unordered_map<MacroName, std::pair<int, MTLDataType>> ShaderMacroCollection::defaultValue = {
    {HAS_UV, {0, MTLDataTypeBool}},
    {HAS_NORMAL, {0, MTLDataTypeBool}},
    {HAS_TANGENT, {0, MTLDataTypeBool}},
    {HAS_VERTEXCOLOR, {0, MTLDataTypeBool}},
    
    // Blend Shape
    {HAS_BLENDSHAPE, {0, MTLDataTypeBool}},
    {HAS_BLENDSHAPE_NORMAL, {0, MTLDataTypeBool}},
    {HAS_BLENDSHAPE_TANGENT, {0, MTLDataTypeBool}},
    
    // Skin
    {HAS_SKIN, {0, MTLDataTypeBool}},
    {HAS_JOINT_TEXTURE, {0, MTLDataTypeBool}},
    {JOINTS_COUNT, {0, MTLDataTypeInt}},
    
    // Material
    {NEED_ALPHA_CUTOFF, {0, MTLDataTypeBool}},
    {NEED_WORLDPOS, {0, MTLDataTypeBool}},
    {NEED_TILINGOFFSET, {0, MTLDataTypeBool}},
    {HAS_DIFFUSE_TEXTURE, {0, MTLDataTypeBool}},
    {HAS_SPECULAR_TEXTURE, {0, MTLDataTypeBool}},
    {HAS_EMISSIVE_TEXTURE, {0, MTLDataTypeBool}},
    {HAS_NORMAL_TEXTURE, {0, MTLDataTypeBool}},
    {OMIT_NORMAL, {0, MTLDataTypeBool}},
    {HAS_BASE_TEXTURE, {0, MTLDataTypeBool}},
    {HAS_BASE_COLORMAP, {0, MTLDataTypeBool}},
    {HAS_EMISSIVEMAP, {0, MTLDataTypeBool}},
    {HAS_OCCLUSIONMAP, {0, MTLDataTypeBool}},
    {HAS_SPECULARMAP, {0, MTLDataTypeBool}},
    {HAS_GLOSSINESSMAP, {0, MTLDataTypeBool}},
    {HAS_METALMAP, {0, MTLDataTypeBool}},
    {HAS_ROUGHNESSMAP, {0, MTLDataTypeBool}},
    {IS_METALLIC_WORKFLOW, {0, MTLDataTypeBool}},
    
    // Light
    {DIRECT_LIGHT_COUNT, {0, MTLDataTypeInt}},
    {POINT_LIGHT_COUNT, {0, MTLDataTypeInt}},
    {SPOT_LIGHT_COUNT, {0, MTLDataTypeInt}},
    
    // Enviroment
    {HAS_SH, {0, MTLDataTypeBool}},
    {HAS_SPECULAR_ENV, {0, MTLDataTypeBool}},
    
    // Particle Render
    {HAS_PARTICLE_TEXTURE, {0, MTLDataTypeBool}},
    {NEED_ROTATE_TO_VELOCITY, {0, MTLDataTypeBool}},
    {NEED_USE_ORIGIN_COLOR, {0, MTLDataTypeBool}},
    {NEED_SCALE_BY_LIFE_TIME, {0, MTLDataTypeBool}},
    {NEED_FADE_IN, {0, MTLDataTypeBool}},
    {NEED_FADE_OUT, {0, MTLDataTypeBool}},
    {IS_2D, {0, MTLDataTypeBool}},
    
    // Shadow
    {NEED_GENERATE_SHADOW_MAP, {0, MTLDataTypeBool}},
    {SHADOW_MAP_COUNT, {0, MTLDataTypeInt}},
};

MTLFunctionConstantValues* ShaderMacroCollection::defaultFunctionConstant = ShaderMacroCollection::createDefaultFunction();
MTLFunctionConstantValues* ShaderMacroCollection::createDefaultFunction() {
    MTLFunctionConstantValues* functionConstants = [[MTLFunctionConstantValues alloc]init];
    for (size_t i = 0; i < TOTAL_COUNT; i++) {
        const auto macro = ShaderMacroCollection::defaultValue[MacroName(i)];

        int value = macro.first;
        auto type = macro.second;
        if (type == MTLDataTypeBool) {
            bool property;
            if (value == 1) {
                property = true;
            } else {
                property = false;
            }
            [functionConstants setConstantValue:&property type:MTLDataTypeBool atIndex:i];
        } else {
            [functionConstants setConstantValue:&value type:type atIndex:i];
        }
    }
    return functionConstants;
}

void ShaderMacroCollection::unionCollection(const ShaderMacroCollection& left, const ShaderMacroCollection& right,
                                            ShaderMacroCollection& result){
    result._value.insert(left._value.begin(), left._value.end());
    result._value.insert(right._value.begin(), right._value.end());
}

size_t ShaderMacroCollection::hash() {
    std::size_t hash{0U};
    for (int i = 0; i < MacroName::TOTAL_COUNT; i++) {
        math::hash_combine(hash, std::hash<int>{}(_value[MacroName(i)].first));
    }
    return hash;
}


}
