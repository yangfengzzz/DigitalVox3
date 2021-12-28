//
//  render_pipeline.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "render_pipeline.h"
#include "../material/material.h"
#include "../camera.h"
#include "../engine.h"
#include "../renderer.h"
#include "../lighting/direct_light.h"
#include "../lighting/spot_light.h"
#include "../lighting/point_light.h"

namespace vox {
bool RenderPipeline::_compareFromNearToFar(const RenderElement &a, const RenderElement &b) {
    return (a.material->renderQueueType < b.material->renderQueueType) ||
    (a.component->_distanceForSort < b.component->_distanceForSort) ||
    (b.component->_renderSortId < a.component->_renderSortId);
}

bool RenderPipeline::_compareFromFarToNear(const RenderElement &a, const RenderElement &b) {
    return (a.material->renderQueueType < b.material->renderQueueType) ||
    (b.component->_distanceForSort < a.component->_distanceForSort) ||
    (b.component->_renderSortId < a.component->_renderSortId);
}

//MARK: - RenderElement
ShaderProperty RenderPipeline::_shadowMapProp = Shader::createProperty("u_shadowMap", ShaderDataGroup::Enum::Internal);
ShaderProperty RenderPipeline::_cubeShadowMapProp = Shader::createProperty("u_cubeShadowMap", ShaderDataGroup::Enum::Internal);
ShaderProperty RenderPipeline::_shadowDataProp = Shader::createProperty("u_shadowData", ShaderDataGroup::Enum::Internal);
ShaderProperty RenderPipeline::_cubeShadowDataProp = Shader::createProperty("u_cubeShadowData", ShaderDataGroup::Enum::Internal);

RenderPipeline::RenderPipeline(Camera *camera) :
_camera(camera) {
    auto pass = std::make_unique<RenderPass>("default", 0, nullptr);
    _defaultPass = pass.get();
    addRenderPass(std::move(pass));
}

RenderPipeline::~RenderPipeline() {
    _opaqueQueue.clear();
    _alphaTestQueue.clear();
    _transparentQueue.clear();
}

void RenderPipeline::openDebugger() {
    _openDebugger = true;
}

void RenderPipeline::closeDebugger() {
    _openDebugger = false;
}

void RenderPipeline::render(RenderContext &context,
                            std::optional<TextureCubeFace> cubeFace, int mipLevel) {
    // generate shadow map
    const auto &engine = _camera->engine();
    auto &rhi = engine->_hardwareRenderer;
    
    shadowCount = 0;
    _drawSpotShadowMap(context);
    _drawDirectShadowMap(context);
    if (shadowCount) {
        packedTexture = rhi.createTextureArray(shadowMaps.begin(), shadowMaps.begin() + shadowCount, packedTexture);
        shaderData.setData(RenderPipeline::_shadowMapProp, packedTexture);
        shaderData.setData(RenderPipeline::_shadowDataProp, shadowDatas);
    }
    cubeShadowCount = 0;
    _drawPointShadowMap(context);
    if (cubeShadowCount) {
        packedCubeTexture = rhi.createCubeTextureArray(cubeShadowMaps.begin(), cubeShadowMaps.begin() + cubeShadowCount, packedCubeTexture);
        shaderData.setData(RenderPipeline::_cubeShadowMapProp, packedCubeTexture);
        shaderData.setData(RenderPipeline::_cubeShadowDataProp, cubeShadowDatas);
    }
    
    // Composition
    _opaqueQueue.clear();
    _alphaTestQueue.clear();
    _transparentQueue.clear();
    
    _camera->engine()->_componentsManager.callRender(context, _opaqueQueue, _alphaTestQueue, _transparentQueue);
    
    std::sort(_opaqueQueue.begin(), _opaqueQueue.end(), RenderPipeline::_compareFromNearToFar);
    std::sort(_alphaTestQueue.begin(), _alphaTestQueue.end(), RenderPipeline::_compareFromNearToFar);
    std::sort(_transparentQueue.begin(), _transparentQueue.end(), RenderPipeline::_compareFromFarToNear);
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        _drawRenderPass(_renderPassArray[i].get(), _camera, cubeFace, mipLevel);
    }
}

//MARK: - RenderPass
RenderPass *RenderPipeline::defaultRenderPass() {
    return _defaultPass;
}

void RenderPipeline::addRenderPass(std::unique_ptr<RenderPass> &&pass) {
    _renderPassArray.emplace_back(std::move(pass));
    std::sort(_renderPassArray.begin(), _renderPassArray.end(),
              [](const std::unique_ptr<RenderPass> &p1, const std::unique_ptr<RenderPass> &p2) {
        return p1->priority - p2->priority;
    });
}

void RenderPipeline::addRenderPass(const std::string &name,
                                   int priority,
                                   MTLRenderPassDescriptor *renderTarget,
                                   Layer mask) {
    auto renderPass = std::make_unique<RenderPass>(name, priority, renderTarget, mask);
    _renderPassArray.emplace_back(std::move(renderPass));
    std::sort(_renderPassArray.begin(), _renderPassArray.end(),
              [](const std::unique_ptr<RenderPass> &p1, const std::unique_ptr<RenderPass> &p2) {
        return p1->priority - p2->priority;
    });
}

void RenderPipeline::removeRenderPass(const std::string &name) {
    ssize_t index = -1;
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto &pass = _renderPassArray[i];
        if (pass->name == name) index = i;
    }
    
    if (index != -1) {
        _renderPassArray.erase(_renderPassArray.begin() + index);
    }
}

void RenderPipeline::removeRenderPass(const RenderPass *p) {
    ssize_t index = -1;
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto &pass = _renderPassArray[i];
        if (pass->name == p->name) index = i;
    }
    
    if (index != -1) {
        _renderPassArray.erase(_renderPassArray.begin() + index);
    }
}

RenderPass *RenderPipeline::getRenderPass(const std::string &name) {
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto &pass = _renderPassArray[i];
        if (pass->name == name) return pass.get();
    }
    
    return nullptr;
}

//MARK: - Draw Methods
void RenderPipeline::_drawSky(const Sky &sky) {
    const auto &material = sky.material;
    const auto &mesh = sky.mesh;
    if (!material) {
        std::cerr << "The material of sky is not defined." << std::endl;
        return;
    }
    if (!mesh) {
        std::cerr << "The mesh of sky is not defined." << std::endl;
        return;
    }
    
    const auto &engine = _camera->engine();
    auto &rhi = engine->_hardwareRenderer;
    auto &shaderData = material->shaderData;
    
    auto compileMacros = ShaderMacroCollection();
    shaderData.mergeMacro(_camera->_globalShaderMacro, compileMacros);
    
    const auto projectionMatrix = _camera->projectionMatrix();
    auto _matrix = _camera->viewMatrix();
    _matrix.elements[12] = 0;
    _matrix.elements[13] = 0;
    _matrix.elements[14] = 0;
    _matrix.elements[15] = 1;
    _matrix = projectionMatrix * _matrix;
    shaderData.setData("u_mvpNoscale", _matrix);
    
    auto program = material->shader->findShaderProgram(engine, compileMacros);
    if (!program->isValid()) {
        return;
    }
    
    auto descriptor = [[MTLRenderPipelineDescriptor alloc] init];
    descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh->vertexDescriptor());
    descriptor.vertexFunction = program->vertexShader();
    descriptor.fragmentFunction = program->fragmentShader();
    
    descriptor.colorAttachments[0].pixelFormat = engine->_hardwareRenderer.colorPixelFormat();
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    auto depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
    material->renderState._apply(engine, descriptor, depthStencilDescriptor);
    auto depthStencilState = rhi.createDepthStencilState(depthStencilDescriptor);
    rhi.setDepthStencilState(depthStencilState);
    
    auto pipelineState = rhi.resouceCache.request_graphics_pipeline(descriptor);
    rhi.setRenderPipelineState(pipelineState);
    
    pipelineState->uploadAll(pipelineState->materialUniformBlock, shaderData);
    
    auto &buffers = mesh->_vertexBuffer;
    for (uint32_t index = 0; index < buffers.size(); index++) {
        rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
    }
    rhi.drawPrimitive(mesh->subMesh(0));
}

void RenderPipeline::_drawPointShadowMap(RenderContext &context) {
    const auto &engine = _camera->engine();
    auto &rhi = engine->_hardwareRenderer;
    
    const auto &lights = context.scene()->light_manager.pointLights();
    for (const auto &light: lights) {
        if (light->enableShadow()) {
            id <MTLTexture> texture = nullptr;
            if (cubeShadowCount < cubeShadowMaps.size()) {
                texture = cubeShadowMaps[cubeShadowCount];
            } else {
                texture = rhi.resourceLoader()->buildCubeTexture(shadowMapSize,
                                                                 MTLPixelFormatDepth32Float);
                cubeShadowMaps.push_back(texture);
            }
            
            light->updateShadowMatrix();
            for (int i = 0; i < 6; i++) {
                if (cubeMapSlices[i] == nullptr) {
                    cubeMapSlices[i] = rhi.resourceLoader()->buildTexture(shadowMapSize, shadowMapSize,
                                                                          MTLPixelFormatDepth32Float);
                }
                
                MTLRenderPassDescriptor *shadowRenderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
                shadowRenderPassDescriptor.depthAttachment.texture = cubeMapSlices[i];
                shadowRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
                shadowRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
                shadowRenderPassDescriptor.depthAttachment.clearDepth = 1;
                rhi.activeRenderTarget(shadowRenderPassDescriptor);
                rhi.beginRenderPass(shadowRenderPassDescriptor, _camera, 0);
                
                MTLDepthStencilDescriptor *depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
                depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
                depthStencilDescriptor.depthWriteEnabled = true;
                auto depthStencilState = rhi.createDepthStencilState(depthStencilDescriptor);
                rhi.setDepthStencilState(depthStencilState);
                rhi.setCullMode(MTLCullModeNone);
                rhi.setDepthBias(0.01, 1.0, 0.01);
                
                std::vector<RenderElement> opaqueQueue{};
                std::vector<RenderElement> transparentQueue{};
                std::vector<RenderElement> alphaTestQueue{};
                
                BoundingFrustum frustum;
                frustum.calculateFromMatrix(light->shadow.vp[i]);
                engine->_componentsManager.callRender(frustum, opaqueQueue, alphaTestQueue, transparentQueue);
                if (cubeShadowCount < LightManager::MAX_CUBE_SHADOW) {
                    cubeShadowDatas[cubeShadowCount] = light->shadow;
                } else {
                    std::cerr << "too much shadow caster!" << std::endl;
                }
                
                for (const auto &element: opaqueQueue) {
                    if (element.component->castShadow) {
                        Shader shader("shadowMap", "vertex_depth", "");
                        auto program = shader.findShaderProgram(engine, element.component->_globalShaderMacro);
                        
                        MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
                        pipelineDescriptor.vertexFunction = program->vertexShader();
                        pipelineDescriptor.fragmentFunction = NULL;
                        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatInvalid;
                        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh->vertexDescriptor());
                        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
                        const auto &pipelineState = rhi.resouceCache.request_graphics_pipeline(pipelineDescriptor);
                        rhi.setRenderPipelineState(pipelineState);
                        
                        auto modelMatrix = element.component->entity()->transform->worldMatrix();
                        rhi.setVertexBytes(light->shadow.vp[i], 11);
                        rhi.setVertexBytes(modelMatrix, 12);
                        
                        auto &buffers = element.mesh->_vertexBuffer;
                        for (uint32_t index = 0; index < buffers.size(); index++) {
                            rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
                        }
                        rhi.drawPrimitive(element.subMesh);
                    }
                }
                
                // render loop
                rhi.endRenderPass();
            }
            texture = rhi.createCubeAtlas(cubeMapSlices, texture);
            cubeShadowCount++;
        }
    }
}

void RenderPipeline::_drawSpotShadowMap(RenderContext &context) {
    const auto &engine = _camera->engine();
    auto &rhi = engine->_hardwareRenderer;
    
    const auto &lights = context.scene()->light_manager.spotLights();
    for (const auto &light: lights) {
        if (light->enableShadow()) {
            id <MTLTexture> texture = nullptr;
            if (shadowCount < shadowMaps.size()) {
                texture = shadowMaps[shadowCount];
            } else {
                texture = rhi.resourceLoader()->buildTexture(shadowMapSize, shadowMapSize,
                                                             MTLPixelFormatDepth32Float);
                shadowMaps.push_back(texture);
            }
            
            MTLRenderPassDescriptor *shadowRenderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
            shadowRenderPassDescriptor.depthAttachment.texture = texture;
            shadowRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
            shadowRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
            shadowRenderPassDescriptor.depthAttachment.clearDepth = 1;
            rhi.activeRenderTarget(shadowRenderPassDescriptor);
            rhi.beginRenderPass(shadowRenderPassDescriptor, _camera, 0);
            
            MTLDepthStencilDescriptor *depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
            depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
            depthStencilDescriptor.depthWriteEnabled = true;
            auto depthStencilState = rhi.createDepthStencilState(depthStencilDescriptor);
            rhi.setDepthStencilState(depthStencilState);
            rhi.setCullMode(MTLCullModeNone);
            rhi.setDepthBias(0.01, 1.0, 0.01);
            
            std::vector<RenderElement> opaqueQueue{};
            std::vector<RenderElement> transparentQueue{};
            std::vector<RenderElement> alphaTestQueue{};
            light->updateShadowMatrix();
            BoundingFrustum frustum;
            frustum.calculateFromMatrix(light->shadow.vp[0]);
            engine->_componentsManager.callRender(frustum, opaqueQueue, alphaTestQueue, transparentQueue);
            if (shadowCount < LightManager::MAX_SHADOW) {
                shadowDatas[shadowCount] = light->shadow;
            } else {
                std::cerr << "too much shadow caster!" << std::endl;
            }
            
            for (const auto &element: opaqueQueue) {
                if (element.component->castShadow) {
                    Shader shader("shadowMap", "vertex_depth", "");
                    auto program = shader.findShaderProgram(engine, element.component->_globalShaderMacro);
                    
                    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
                    pipelineDescriptor.vertexFunction = program->vertexShader();
                    pipelineDescriptor.fragmentFunction = NULL;
                    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatInvalid;
                    pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh->vertexDescriptor());
                    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
                    const auto &pipelineState = rhi.resouceCache.request_graphics_pipeline(pipelineDescriptor);
                    rhi.setRenderPipelineState(pipelineState);
                    
                    auto modelMatrix = element.component->entity()->transform->worldMatrix();
                    rhi.setVertexBytes(light->shadow.vp, 11);
                    rhi.setVertexBytes(modelMatrix, 12);
                    
                    auto &buffers = element.mesh->_vertexBuffer;
                    for (uint32_t index = 0; index < buffers.size(); index++) {
                        rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
                    }
                    rhi.drawPrimitive(element.subMesh);
                }
            }
            
            // render loop
            rhi.endRenderPass();
            shadowCount++;
        }
    }
}

void RenderPipeline::_drawDirectShadowMap(RenderContext &context) {
    const auto &engine = _camera->engine();
    auto &rhi = engine->_hardwareRenderer;
    
    const auto &lights = context.scene()->light_manager.directLights();
    for (const auto &light: lights) {
        if (light->enableShadow()) {
            id <MTLTexture> texture = nullptr;
            if (shadowCount < shadowMaps.size()) {
                texture = shadowMaps[shadowCount];
            } else {
                texture = rhi.resourceLoader()->buildTexture(shadowMapSize, shadowMapSize,
                                                             MTLPixelFormatDepth32Float);
                shadowMaps.push_back(texture);
            }
            
            _updateCascades(light);
            for (int i = 0; i < SHADOW_MAP_CASCADE_COUNT; i++) {
                if (cascadeShadowMaps[i] == nullptr) {
                    cascadeShadowMaps[i] = rhi.resourceLoader()->buildTexture(shadowMapSize / 2, shadowMapSize / 2,
                                                                              MTLPixelFormatDepth32Float);
                }
                
                MTLRenderPassDescriptor *shadowRenderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
                shadowRenderPassDescriptor.depthAttachment.texture = cascadeShadowMaps[i];
                shadowRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
                shadowRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
                shadowRenderPassDescriptor.depthAttachment.clearDepth = 1;
                rhi.activeRenderTarget(shadowRenderPassDescriptor);
                rhi.beginRenderPass(shadowRenderPassDescriptor, _camera, 0);
                
                MTLDepthStencilDescriptor *depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
                depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
                depthStencilDescriptor.depthWriteEnabled = true;
                auto depthStencilState = rhi.createDepthStencilState(depthStencilDescriptor);
                rhi.setDepthStencilState(depthStencilState);
                rhi.setCullMode(MTLCullModeNone);
                rhi.setDepthBias(0.01, 1.0, 0.01);
                
                std::vector<RenderElement> opaqueQueue{};
                std::vector<RenderElement> transparentQueue{};
                std::vector<RenderElement> alphaTestQueue{};
                BoundingFrustum frustum;
                frustum.calculateFromMatrix(shadowDatas[shadowCount].vp[i]);
                engine->_componentsManager.callRender(frustum, opaqueQueue, alphaTestQueue, transparentQueue);
                if (shadowCount < LightManager::MAX_SHADOW) {
                    shadowDatas[shadowCount].radius = light->shadow.radius;
                    shadowDatas[shadowCount].intensity = light->shadow.intensity;
                    shadowDatas[shadowCount].bias = light->shadow.bias;
                } else {
                    std::cerr << "too much shadow caster!" << std::endl;
                }
                
                for (const auto &element: opaqueQueue) {
                    if (element.component->castShadow) {
                        Shader shader("shadowMap", "vertex_depth", "");
                        auto program = shader.findShaderProgram(engine, element.component->_globalShaderMacro);
                        
                        MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
                        pipelineDescriptor.vertexFunction = program->vertexShader();
                        pipelineDescriptor.fragmentFunction = NULL;
                        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatInvalid;
                        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh->vertexDescriptor());
                        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
                        const auto &pipelineState = rhi.resouceCache.request_graphics_pipeline(pipelineDescriptor);
                        rhi.setRenderPipelineState(pipelineState);
                        
                        auto modelMatrix = element.component->entity()->transform->worldMatrix();
                        rhi.setVertexBytes(shadowDatas[shadowCount].vp[i], 11);
                        rhi.setVertexBytes(modelMatrix, 12);
                        
                        auto &buffers = element.mesh->_vertexBuffer;
                        for (uint32_t index = 0; index < buffers.size(); index++) {
                            rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
                        }
                        rhi.drawPrimitive(element.subMesh);
                    }
                }
                
                // render loop
                rhi.endRenderPass();
            }
            texture = rhi.createAtlas(cascadeShadowMaps, texture);
            shadowCount++;
        }
    }
}

void RenderPipeline::_updateCascades(DirectLight *light) {
    std::array<float, SHADOW_MAP_CASCADE_COUNT> cascadeSplits{};
    auto worldPos = light->entity()->transform->worldPosition();
    
    float nearClip = _camera->nearClipPlane();
    float farClip = _camera->farClipPlane();
    float clipRange = farClip - nearClip;
    
    float minZ = nearClip;
    float maxZ = nearClip + clipRange;
    
    float range = maxZ - minZ;
    float ratio = maxZ / minZ;
    
    // Calculate split depths based on view camera frustum
    // Based on method presented in https://developer.nvidia.com/gpugems/GPUGems3/gpugems3_ch10.html
    for (uint32_t i = 0; i < SHADOW_MAP_CASCADE_COUNT; i++) {
        float p = (i + 1) / static_cast<float>(SHADOW_MAP_CASCADE_COUNT);
        float log = minZ * std::pow(ratio, p);
        float uniform = minZ + range * p;
        float d = cascadeSplitLambda * (log - uniform) + uniform;
        cascadeSplits[i] = (d - nearClip) / clipRange;
    }
    
    std::array<math::Float3, 8> frustumCorners = {
        math::Float3(-1.0f, 1.0f, 0.0f),
        math::Float3(1.0f, 1.0f, 0.0f),
        math::Float3(1.0f, -1.0f, 0.0f),
        math::Float3(-1.0f, -1.0f, 0.0f),
        math::Float3(-1.0f, 1.0f, 1.0f),
        math::Float3(1.0f, 1.0f, 1.0f),
        math::Float3(1.0f, -1.0f, 1.0f),
        math::Float3(-1.0f, -1.0f, 1.0f),
    };
    
    // Project frustum corners into world space
    Matrix invCam = math::invert(_camera->projectionMatrix() * _camera->viewMatrix());
    for (uint32_t i = 0; i < 8; i++) {
        Float4 invCorner = transformToVec4(frustumCorners[i], invCam);
        frustumCorners[i] = invCorner.xyz() / invCorner.w;
    }
    
    // Calculate orthographic projection matrix for each cascade
    float lastSplitDist = 0.0;
    for (uint32_t i = 0; i < SHADOW_MAP_CASCADE_COUNT; i++) {
        float splitDist = cascadeSplits[i];
        std::array<math::Float3, 8> _frustumCorners = frustumCorners;
        
        for (uint32_t i = 0; i < 4; i++) {
            Float3 dist = _frustumCorners[i + 4] - _frustumCorners[i];
            _frustumCorners[i + 4] = _frustumCorners[i] + (dist * splitDist);
            _frustumCorners[i] = _frustumCorners[i] + (dist * lastSplitDist);
        }
        
        auto lightMat = light->entity()->transform->worldMatrix();
        auto lightViewMat = invert(lightMat);
        for (uint32_t i = 0; i < 8; i++) {
            _frustumCorners[i] = transformCoordinate(_frustumCorners[i], lightViewMat);
        }
        float farDist = Length(_frustumCorners[7] - _frustumCorners[5]);
        float crossDist = Length(_frustumCorners[7] - _frustumCorners[1]);
        float maxDist = farDist > crossDist ? farDist : crossDist;
        
        float minX = std::numeric_limits<float>::infinity();
        float maxX = -std::numeric_limits<float>::infinity();
        float minY = std::numeric_limits<float>::infinity();
        float maxY = -std::numeric_limits<float>::infinity();
        float minZ = std::numeric_limits<float>::infinity();
        float maxZ = -std::numeric_limits<float>::infinity();
        for (uint32_t i = 0; i < 8; i++) {
            minX = std::min(minX, _frustumCorners[i].x);
            maxX = std::max(maxX, _frustumCorners[i].x);
            minY = std::min(minY, _frustumCorners[i].y);
            maxY = std::max(maxY, _frustumCorners[i].y);
            minZ = std::min(minZ, _frustumCorners[i].z);
            maxZ = std::max(maxZ, _frustumCorners[i].z);
        }
        
        // texel tile
        float fWorldUnitsPerTexel = maxDist / (float) 1000;
        float posX = (minX + maxX) * 0.5f;
        posX /= fWorldUnitsPerTexel;
        posX = floor(posX);
        posX *= fWorldUnitsPerTexel;
        
        float posY = (minY + maxY) * 0.5f;
        posY /= fWorldUnitsPerTexel;
        posY = floor(posY);
        posY *= fWorldUnitsPerTexel;
        
        float posZ = maxZ;
        posZ /= fWorldUnitsPerTexel;
        posZ = floor(posZ);
        posZ *= fWorldUnitsPerTexel;
        
        Float3 center = Float3(posX, posY, posZ);
        center = transformCoordinate(center, lightMat);
        light->entity()->transform->setWorldPosition(center);
        
        float radius = maxDist / 2.0;
        Float3 maxExtents = Float3(radius);
        Float3 minExtents = -maxExtents;
        Matrix lightOrthoMatrix = Matrix::ortho(minExtents.x, maxExtents.x, minExtents.y, maxExtents.y, 0.0f, maxZ - minZ);
        
        // Store split distance and matrix in cascade
        shadowDatas[shadowCount].cascadeSplits[i] = (_camera->nearClipPlane() + splitDist * clipRange) * -1.0f;
        auto vp = lightOrthoMatrix * invert(light->entity()->transform->worldMatrix());
        shadowDatas[shadowCount].vp[i] = vp.toSimdMatrix();
        light->entity()->transform->setWorldPosition(worldPos);
        lastSplitDist = cascadeSplits[i];
    }
}

}
