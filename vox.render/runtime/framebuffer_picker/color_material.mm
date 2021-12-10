//
//  color_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#include "color_material.h"
#include "../renderer.h"
#include "../render_pipeline/render_element.h"
#include "../../log.h"

namespace vox {
namespace picker {
ShaderProperty ColorMaterial::_colorProp = Shader::createProperty("u_colorId", ShaderDataGroup::Renderer);

ColorMaterial::ColorMaterial(Engine* engine):
Material(engine, Shader::find("framebuffer-picker-color")){
}

void ColorMaterial::reset() {
    _currentId = 0;
    _primitivesMap.clear();
}

math::Float3 ColorMaterial::id2Color(uint32_t id) {
    if (id >= 0xffffff) {
        std::cout<< "Framebuffer Picker encounter primitive's id greater than " + std::to_string(0xffffff) <<std::endl;
        return math::Float3(0, 0, 0);
    }
    
    return math::Float3((id & 0xff) / 255.0, ((id & 0xff00) >> 8) / 255.0, ((id & 0xff0000) >> 16) / 255.0);
}

uint32_t ColorMaterial::color2Id(const std::array<uint8_t, 4>& color) {
    return color[0] | (color[1] << 8) | (color[2] << 16);
}

std::pair<Renderer*, MeshPtr> ColorMaterial::getObjectByColor(const std::array<uint8_t, 4>& color) {
    auto iter = _primitivesMap.find(color2Id(color));
    if (iter != _primitivesMap.end()) {
        return iter->second;
    } else {
        return std::make_pair(nullptr, nullptr);
    }
}

void ColorMaterial::_preRender(const RenderElement& renderElement) {
    _currentId += 1;
    _primitivesMap[_currentId] = std::make_pair(renderElement.component, renderElement.mesh);
    renderElement.component->shaderData.setData("u_colorId", id2Color(_currentId));
}

}
}
