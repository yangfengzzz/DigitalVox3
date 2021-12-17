//
//  skybox_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/17.
//

#ifndef skybox_material_hpp
#define skybox_material_hpp

#include "../material/material.h"
#include "maths/vec_float.h"

namespace vox {
/**
 * SkyboxMaterial
 */
class SkyBoxMaterial :public Material {
public:
    /**
     * Whether to decode from texture with RGBM format.
     */
    bool textureDecodeRGBM();

    void setTextureDecodeRGBM(bool value);

    /**
     * RGBM decode factor, default 5.0.
     */
    float RGBMDecodeFactor();

    void setRGBMDecodeFactor(float value);
        
    /**
     * Texture cube map of the sky box material.
     */
    id<MTLTexture> textureCubeMap();

    void setTextureCubeMap(id<MTLTexture> v);

    SkyBoxMaterial(Engine* engine);
    
private:
    static ShaderProperty _skyboxTextureProp;
    static ShaderProperty _mvpNoscaleProp;

    math::Float2 _decodeParam = math::Float2(0, 5);
};
}

#endif /* skybox_material_hpp */
