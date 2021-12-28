//
//  unlit_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#ifndef unlit_material_hpp
#define unlit_material_hpp

#include "base_material.h"
#include "maths/vec_float.h"

namespace vox {
/**
 * Unlit Material.
 */
class UnlitMaterial : public BaseMaterial {
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
     * Tiling and offset of main textures.
     */
    math::Float4 tilingOffset();
    
    void setTilingOffset(const math::Float4 &newValue);
    
    /**
     * Create a unlit material instance.
     * @param engine - Engine to which the material belongs
     */
    explicit UnlitMaterial(Engine *engine);
    
private:
    static ShaderProperty _baseColorProp;
    static ShaderProperty _baseTextureProp;
    static ShaderProperty _tilingOffsetProp;
};

}

#endif /* unlit_material_hpp */
