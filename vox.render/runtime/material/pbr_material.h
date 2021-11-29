//
//  pbr_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#ifndef pbr_material_hpp
#define pbr_material_hpp

#include "pbr_base_material.h"

namespace vox {
/// PBR (Metallic-Roughness Workflow) Material.
class PBRMaterial: public PBRBaseMaterial {
public:
    /// Metallic.
    float metallic();
    void setMetallic(float newValue);
    
    /// Roughness.
    float roughness();
    void setRoughness(float newValue);
    
    /// Roughness metallic texture.
    id<MTLTexture> roughnessTexture();
    void setRoughnessTexture(id<MTLTexture> newValue);
    
    /// Roughness metallic texture.
    id<MTLTexture> metallicTexture();
    void setMetallicTexture(id<MTLTexture> newValue);
    
    /// Create a pbr metallic-roughness workflow material instance.
    /// - Parameter engine: Engine to which the material belongs
    PBRMaterial(Engine* engine);
    
private:
    static ShaderProperty _metallicProp;
    static ShaderProperty _roughnessProp;
    static ShaderProperty _metallicTextureProp;
    static ShaderProperty _roughnessTextureProp;
};

}

#endif /* pbr_material_hpp */
