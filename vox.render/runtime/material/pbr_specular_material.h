//
//  pbr_specular_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#ifndef pbr_specular_material_hpp
#define pbr_specular_material_hpp

#include "pbr_base_material.h"

namespace vox {
/**
 * PBR (Specular-Glossiness Workflow) Material.
 */
class PBRSpecularMaterial : public PBRBaseMaterial {
public:
    /**
     * Specular color.
     */
    math::Color specularColor();
    
    void setSpecularColor(const math::Color &newValue);
    
    /**
     * Glossiness.
     */
    float glossiness();
    
    void setGlossiness(float newValue);
    
    /**
     * Specular glossiness texture.
     * @remarks RGB is specular, A is glossiness
     */
    id <MTLTexture> specularGlossinessTexture();
    
    void setSpecularGlossinessTexture(id <MTLTexture> newValue);
    
    /**
     * Create a pbr specular-glossiness workflow material instance.
     * @param engine - Engine to which the material belongs
     */
    explicit PBRSpecularMaterial(Engine *engine);
    
private:
    static ShaderProperty _glossinessProp;
    static ShaderProperty _specularColorProp;
    static ShaderProperty _specularGlossinessTextureProp;
};

}

#endif /* pbr_specular_material_hpp */
