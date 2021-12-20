//
//  shadow_map_pass.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#include "shadow_map_pass.h"
#include "../shader/shader.h"
#include "../material/material.h"

namespace vox {
ShaderProperty ShadowMapPass::_viewMatFromLightProperty = Shader::createProperty("u_viewMatFromLight", ShaderDataGroup::Enum::Scene);
ShaderProperty ShadowMapPass::_projMatFromLightProperty = Shader::createProperty("u_projMatFromLight", ShaderDataGroup::Enum::Scene);
ShadowMapPass::ShadowMapPass(const std::string& name, int priority,
                             MTLRenderPassDescriptor* renderTarget,
                             MaterialPtr replaceMaterial,
                             Layer mask,  Light* light):
RenderPass(name, priority, renderTarget, mask),
_shadowMapMaterial(replaceMaterial),
light(light) {
    clearColor = Color(1, 1, 1, 1);
}

void ShadowMapPass::preRender(Camera* camera, const RenderQueue& opaqueQueue,
                              const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) {
    // The viewProjection matrix from the light.
    auto& shaderData = _shadowMapMaterial->shaderData;
    shaderData.setData(ShadowMapPass::_viewMatFromLightProperty, light->viewMatrix());
    // shaderData.setData(ShadowMapPass::_projMatFromLightProperty, light->shadow->projectionMatrix());
}

}
