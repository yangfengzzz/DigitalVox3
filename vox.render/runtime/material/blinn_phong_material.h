//
//  blinn_phong_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#ifndef blinn_phong_material_hpp
#define blinn_phong_material_hpp

#include "base_material.h"
#include "maths/vec_float.h"

namespace vox {
/**
 * Blinn-phong Material.
 */
class BlinnPhongMaterial : public BaseMaterial {
public:
    /**
     * Base color.
     */
    math::Color baseColor();
    
    void setBaseColor(const math::Color &newValue);
    
    /**
     * Base texture.
     */
    id <MTLTexture> baseTexture();
    
    void setBaseTexture(id <MTLTexture> newValue);
    
    /**
     * Specular color.
     */
    math::Color specularColor();
    
    void setSpecularColor(const math::Color &newValue);
    
    /**
     * Specular texture.
     */
    id <MTLTexture> specularTexture();
    
    void setSpecularTexture(id <MTLTexture> newValue);
    
    /**
     * Emissive color.
     */
    math::Color emissiveColor();
    
    void setEmissiveColor(const math::Color &newValue);
    
    /**
     * Emissive texture.
     */
    id <MTLTexture> emissiveTexture();
    
    void setEmissiveTexture(id <MTLTexture> newValue);
    
    /**
     * Normal texture.
     */
    id <MTLTexture> normalTexture();
    
    void setNormalTexture(id <MTLTexture> newValue);
    
    /**
     * Normal texture intensity.
     */
    float normalIntensity();
    
    void setNormalIntensity(float newValue);
    
    /**
     * Set the specular reflection coefficient, the larger the value, the more convergent the specular reflection effect.
     */
    float shininess();
    
    void setShininess(float newValue);
    
    /**
     * Tiling and offset of main textures.
     */
    math::Float4 tilingOffset();
    
    void setTilingOffset(const math::Float4 &newValue);
    
    explicit BlinnPhongMaterial(Engine *engine);
    
private:
    static ShaderProperty _diffuseColorProp;
    static ShaderProperty _specularColorProp;
    static ShaderProperty _emissiveColorProp;
    static ShaderProperty _tilingOffsetProp;
    static ShaderProperty _shininessProp;
    static ShaderProperty _normalIntensityProp;
    
    static ShaderProperty _baseTextureProp;
    static ShaderProperty _specularTextureProp;
    static ShaderProperty _emissiveTextureProp;
    static ShaderProperty _normalTextureProp;
};


}

#endif /* blinn_phong_material_hpp */
