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
/// PBR (Specular-Glossiness Workflow) Material.
class PBRSpecularMaterial: public PBRBaseMaterial {
public:
    /// Specular color.
    Color specularColor();
    void setSpecularColor(const Color& newValue);
    
    /// Glossiness.
    float glossiness();
    void setGlossiness(float newValue);
    
    /// Specular glossiness texture.
    id<MTLTexture> glossinessTexture();
    void setGlossinessTexture(id<MTLTexture> newValue);
    
    /// Specular glossiness texture.
    id<MTLTexture> specularTexture();
    void setSpecularTexture(id<MTLTexture> newValue);
    
    /// Create a pbr specular-glossiness workflow material instance.
    /// - Parameter engine: Engine to which the material belongs
    PBRSpecularMaterial(Engine* engine);
    
private:
    static ShaderProperty _glossinessProp;
    static ShaderProperty _specularColorProp;
    static ShaderProperty _glossinessTextureProp;
    static ShaderProperty _specularTextureProp;
};

}

#endif /* pbr_specular_material_hpp */
