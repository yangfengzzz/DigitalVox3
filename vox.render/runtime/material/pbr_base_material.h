//
//  pbr_base_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#ifndef pbr_base_material_hpp
#define pbr_base_material_hpp

#include "base_material.h"
#include "maths/vec_float.h"

namespace vox {
/// PBR (Physically-Based Rendering) Material.
class PBRBaseMaterial: public BaseMaterial {
public:
    /// Base color.
    Color baseColor();
    void setBaseColor(const Color& newValue);
    
    /// Base texture.
    id<MTLTexture> baseTexture();
    void setBaseTexture(id<MTLTexture> newValue);
    
    /// Normal texture.
    id<MTLTexture> normalTexture();
    void setNormalTexture(id<MTLTexture> newValue);
    
    /// Normal texture intensity.
    float normalTextureIntensity();
    void setNormalTextureIntensity(float newValue);
    
    /// Emissive color.
    Color emissiveColor();
    void setEmissiveColor(const Color& newValue);
    
    /// Emissive texture.
    id<MTLTexture> emissiveTexture();
    void setEmissiveTexture(id<MTLTexture> newValue);
    
    /// Occlusion texture.
    id<MTLTexture> occlusionTexture();
    void setOcclusionTexture(id<MTLTexture> newValue);
    
    /// Occlusion texture intensity.
    float occlusionTextureIntensity();
    void setOcclusionTextureIntensity(float newValue);
    
    /// Tiling and offset of main textures.
    Float4 tilingOffset();
    void setTilingOffset(const Float4& newValue);
    
    /// Create a pbr base material instance.
    /// - Parameter engine: Engine to which the material belongs
    PBRBaseMaterial(Engine* engine);
    
private:
    static ShaderProperty _tilingOffsetProp;
    static ShaderProperty _normalTextureIntensityProp;
    static ShaderProperty _occlusionTextureIntensityProp;
    
    static ShaderProperty _baseColorProp;
    static ShaderProperty _emissiveColorProp;
    
    static ShaderProperty _baseTextureProp;
    static ShaderProperty _normalTextureProp;
    static ShaderProperty _emissiveTextureProp;
    static ShaderProperty _occlusionTextureProp;
};

}

#endif /* pbr_base_material_hpp */
