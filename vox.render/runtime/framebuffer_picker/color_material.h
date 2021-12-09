//
//  color_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#ifndef color_material_hpp
#define color_material_hpp

#include "maths/vec_float.h"
#include "../material/material.h"
#include <unordered_map>

namespace vox {
namespace picker {
/**
 * Color material, render as marker.
 */
class ColorMaterial :public Material {
public:
    ColorMaterial(Engine* engine);
    
    /**
     * Reset id and renderer element table.
     */
    void reset();
    
    /**
     * Convert id to RGB color value, 0 and 0xffffff are illegal values.
     */
    math::Float3 id2Color(uint32_t id);
    
    /**
     * Convert RGB color to id.
     * @param color - Color
     */
    uint32_t color2Id(const std::array<uint8_t, 4>& color);
    
    /**
     * Get renderer element by color.
     */
    std::pair<Renderer*, MeshPtr> getObjectByColor(const std::array<uint8_t, 4>& color);
    
    void _preRender(const RenderElement& renderElement);
    
private:
    static ShaderProperty _colorProp;

    uint32_t _currentId = 0;
    std::unordered_map<size_t, std::pair<Renderer*, MeshPtr>> _primitivesMap;
};

}
}

#endif /* color_material_hpp */
