//
//  direct_light.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#include "direct_light.h"
#include "../scene.h"
#include "../shader/shader.h"
#include "../entity.h"
#include "../rhi-metal/render_pipeline_state.h"

namespace vox {
ShaderProperty DirectLight::_directLightProperty = Shader::createProperty("u_directLight", ShaderDataGroup::Scene);
std::array<DirectLightData, Light::MAX_LIGHT> DirectLight::_shaderData = {};

DirectLight::DirectLight(Entity* entity):
Light(entity) {
    RenderPipelineState::register_fragment_uploader<std::array<DirectLightData, Light::MAX_LIGHT>>(
    [](const std::array<DirectLightData, Light::MAX_LIGHT>& x, size_t location, id <MTLRenderCommandEncoder> encoder){
        [encoder setFragmentBytes: x.data() length:sizeof(std::array<DirectLightData, Light::MAX_LIGHT>) atIndex:location];
    });
}

void DirectLight::_appendData(size_t lightIndex) {
    _shaderData[lightIndex].color = simd_make_float3(color.r * intensity, color.g * intensity, color.b * intensity);
    auto direction = entity()->transform->worldForward();
    _shaderData[lightIndex].direction = simd_make_float3(direction.x, direction.y, direction.z);
}

void DirectLight::_updateShaderData(ShaderData& shaderData) {
    shaderData.setData(DirectLight::_directLightProperty, _shaderData);
}

math::Float3 DirectLight::direction() {
    return entity()->transform->worldForward();
}

math::Matrix DirectLight::shadowProjectionMatrix() {
    assert(false && "cascade shadow don't use this projection");
}

void DirectLight::_onEnable() {
    scene()->light_manager.attachDirectLight(this);
}

void DirectLight::_onDisable() {
    scene()->light_manager.detachDirectLight(this);
}

}
