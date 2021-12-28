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
/**
 * PBR (Metallic-Roughness Workflow) Material.
 */
class PBRMaterial : public PBRBaseMaterial {
public:
    /**
     * Metallic.
     */
    float metallic();
    
    void setMetallic(float newValue);
    
    /**
     * Roughness.
     */
    float roughness();
    
    void setRoughness(float newValue);
    
    /**
     * Roughness metallic texture.
     * @remarks G channel is roughness, B channel is metallic
     */
    id <MTLTexture> metallicRoughnessTexture();
    
    void setMetallicRoughnessTexture(id <MTLTexture> newValue);
    
    /**
     * Create a pbr metallic-roughness workflow material instance.
     * @param engine - Engine to which the material belongs
     */
    explicit PBRMaterial(Engine *engine);
    
private:
    static ShaderProperty _metallicProp;
    static ShaderProperty _roughnessProp;
    static ShaderProperty _metallicRoughnessTextureProp;
};

}

#endif /* pbr_material_hpp */
