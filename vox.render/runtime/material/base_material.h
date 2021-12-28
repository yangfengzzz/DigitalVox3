//
//  base_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#ifndef base_material_hpp
#define base_material_hpp

#include "material.h"
#include "enums/render_face.h"
#include "enums/blend_mode.h"

namespace vox {
class BaseMaterial : public Material {
public:
    /**
     * Is this material transparent.
     * @remarks
     * If material is transparent, transparent blend mode will be affected by `blendMode`, default is `BlendMode.Normal`.
     */
    bool isTransparent();
    
    void setIsTransparent(bool newValue);
    
    /**
     * Alpha cutoff value.
     * @remarks
     * Fragments with alpha channel lower than cutoff value will be discarded.
     * `0` means no fragment will be discarded.
     */
    float alphaCutoff();
    
    void setAlphaCutoff(float newValue);
    
    /**
     * Set which face for render.
     */
    const RenderFace::Enum &renderFace();
    
    void setRenderFace(const RenderFace::Enum &newValue);
    
    /**
     * Alpha blend mode.
     * @remarks
     * Only take effect when `isTransparent` is `true`.
     */
    const BlendMode::Enum &blendMode();
    
    void setBlendMode(const BlendMode::Enum &newValue);
    
    /**
     * Create a BaseMaterial instance.
     * @param engine - Engine to which the material belongs
     * @param shader - Shader used by the material
     */
    BaseMaterial(Engine *engine, Shader *shader);
    
private:
    static ShaderProperty _alphaCutoffProp;
    
    RenderFace::Enum _renderFace = RenderFace::Enum::Back;
    bool _isTransparent = false;
    BlendMode::Enum _blendMode = BlendMode::Enum::Normal;
};

}
#endif /* base_material_hpp */
