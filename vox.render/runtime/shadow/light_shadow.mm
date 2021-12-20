//
//  light_shadow.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#include "light_shadow.h"
#include "../shader/shader.h"
#include "../lighting/direct_light.h"
#include "../lighting/point_light.h"
#include "../lighting/spot_light.h"
#include "../engine.h"

namespace vox {
ShaderProperty LightShadow::_viewMatFromLightProperty = Shader::createProperty("u_viewMatFromLight", ShaderDataGroup::Enum::Scene);
ShaderProperty LightShadow::_projMatFromLightProperty = Shader::createProperty("u_projMatFromLight", ShaderDataGroup::Enum::Scene);
ShaderProperty LightShadow::_shadowBiasProperty = Shader::createProperty("u_shadowBias", ShaderDataGroup::Enum::Scene);
ShaderProperty LightShadow::_shadowIntensityProperty = Shader::createProperty("u_shadowIntensity", ShaderDataGroup::Enum::Scene);
ShaderProperty LightShadow::_shadowRadiusProperty = Shader::createProperty("u_shadowRadius", ShaderDataGroup::Enum::Scene);
ShaderProperty LightShadow::_shadowMapSizeProperty = Shader::createProperty("u_shadowMapSize", ShaderDataGroup::Enum::Scene);
ShaderProperty LightShadow::_shadowMapsProperty = Shader::createProperty("u_shadowMaps", ShaderDataGroup::Enum::Scene);

LightShadow::CombiendData LightShadow::_combinedData;

void LightShadow::clearMap() {
    for (int i = 0; i < maxLight; i++) {
        _combinedData.map[i] = nullptr;
    }
}

LightShadow::LightShadow(Light* light, Engine* engine, float width, float height):
light(light) {
    _mapSize = math::Float2(width, height);
    
    auto metalResourceLoader = engine->resourceLoader();
    _renderTarget.colorAttachments[0].texture =
    metalResourceLoader->buildTexture(width, height, MTLPixelFormatBGRA8Unorm,
                                      MTLTextureUsageRenderTarget, MTLStorageModeManaged);
    _renderTarget.depthAttachment.texture =
    metalResourceLoader->buildTexture(width, height, MTLPixelFormatDepth32Float);
}

MTLRenderPassDescriptor* LightShadow::renderTarget() {
    return _renderTarget;
}

id<MTLTexture> LightShadow::map() {
    return _renderTarget.colorAttachments[0].texture;
}

math::Float2 LightShadow::mapSize() {
    return _mapSize;
}

void LightShadow::initShadowProjectionMatrix(Light* light) {
    /**
     * Directional light projection matrix, the default coverage area is left: -5, right: 5, bottom: -5, up: 5, near: 0.5, far: 50.
     */
    if (dynamic_cast<DirectLight*>(light)) {
        projectionMatrix = math::Matrix::ortho(-5, 5, -5, 5, 0.1, 50);
    }
    
    /**
     * Point light projection matrix, default configuration: fov: 50, aspect: 1, near: 0.5, far: 50.
     */
    if (dynamic_cast<PointLight*>(light)) {
        projectionMatrix = math::Matrix::perspective(math::degreeToRadian(50), 1, 0.5, 50);
    }
    
    /**
     * Spotlight projection matrix, the default configuration: fov: this.angle * 2 * Math.sqrt(2), aspect: 1, near: 0.1, far: this.distance + 5
     */
    auto spot = dynamic_cast<SpotLight*>(light);
    if (spot) {
        const auto fov = std::min(M_PI / 2, spot->angle * 2 * std::sqrt(2));
        projectionMatrix = math::Matrix::perspective(fov, 1, 0.1, spot->distance + 5);
    }
}

void LightShadow::appendData(int lightIndex) {
    _combinedData.viewMatrix[lightIndex] = light->viewMatrix();
    _combinedData.projectionMatrix[lightIndex] = projectionMatrix;
    _combinedData.bias[lightIndex] = bias;
    _combinedData.intensity[lightIndex] = intensity;
    _combinedData.radius[lightIndex] = radius;
    _combinedData.mapSize[lightIndex] = mapSize();
    _combinedData.map[lightIndex] = map();
}

void LightShadow::_updateShaderData(ShaderData& shaderData) {
    shaderData.setData(LightShadow::_viewMatFromLightProperty, _combinedData.viewMatrix);
    shaderData.setData(LightShadow::_projMatFromLightProperty, _combinedData.projectionMatrix);
    shaderData.setData(LightShadow::_shadowBiasProperty, _combinedData.bias);
    shaderData.setData(LightShadow::_shadowIntensityProperty, _combinedData.intensity);
    shaderData.setData(LightShadow::_shadowRadiusProperty, _combinedData.radius);
    shaderData.setData(LightShadow::_shadowMapSizeProperty, _combinedData.mapSize);
    shaderData.setData(LightShadow::_shadowMapsProperty, _combinedData.map);
}

}
