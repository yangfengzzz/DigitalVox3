//
//  basic_render_pipeline.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "basic_render_pipeline.h"
#include "../material/material.h"
#include "../camera.h"
#include "../engine.h"
#include "../renderer.h"
#include "../lighting/direct_light.h"

namespace vox {
bool BasicRenderPipeline::_compareFromNearToFar(const RenderElement& a, const RenderElement& b) {
    return (a.material->renderQueueType < b.material->renderQueueType) ||
    (a.component->_distanceForSort < b.component->_distanceForSort) ||
    (b.component->_renderSortId < a.component->_renderSortId);
}

bool BasicRenderPipeline::_compareFromFarToNear(const RenderElement& a, const RenderElement& b) {
    return (a.material->renderQueueType < b.material->renderQueueType) ||
    (b.component->_distanceForSort < a.component->_distanceForSort) ||
    (b.component->_renderSortId < a.component->_renderSortId);
}

//MARK: - RenderElement
ShaderProperty BasicRenderPipeline::_shadowMapProp = Shader::createProperty("u_shadowMap", ShaderDataGroup::Enum::Internal);
ShaderProperty BasicRenderPipeline::_shadowDataProp = Shader::createProperty("u_shadowData", ShaderDataGroup::Enum::Internal);
BasicRenderPipeline::BasicRenderPipeline(Camera* camera):
_camera(camera) {
    auto pass = std::make_unique<RenderPass>("default", 0, nullptr);
    _defaultPass = pass.get();
    addRenderPass(std::move(pass));
}

void BasicRenderPipeline::destroy() {
    _opaqueQueue.clear();
    _alphaTestQueue.clear();
    _transparentQueue.clear();
    _renderPassArray.clear();
}

void BasicRenderPipeline::render(RenderContext& context,
                                 std::optional<TextureCubeFace> cubeFace, int mipLevel) {
    // generate shadow map
    shadowCount = 0;
    const auto& engine = _camera->engine();
    auto& rhi = engine->_hardwareRenderer;
    
    _drawShadowMap(context);
    _drawCascadeShadowMap(context);
    if (!shadowMaps.empty()) {
        packedTexture = rhi.mergeResource(shadowMaps.begin(), shadowMaps.begin() + shadowCount, packedTexture);
        shaderData.setData(BasicRenderPipeline::_shadowMapProp, packedTexture);
        shaderData.setData(BasicRenderPipeline::_shadowDataProp, shadowDatas);
    }
    
    // Composition
    _opaqueQueue.clear();
    _alphaTestQueue.clear();
    _transparentQueue.clear();
    
    _camera->engine()->_componentsManager.callRender(context, _opaqueQueue, _alphaTestQueue, _transparentQueue);
    
    std::sort(_opaqueQueue.begin(), _opaqueQueue.end(), BasicRenderPipeline::_compareFromNearToFar);
    std::sort(_alphaTestQueue.begin(), _alphaTestQueue.end(), BasicRenderPipeline::_compareFromNearToFar);
    std::sort(_transparentQueue.begin(), _transparentQueue.end(), BasicRenderPipeline::_compareFromFarToNear);
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        _drawRenderPass(_renderPassArray[i].get(), _camera, cubeFace, mipLevel);
    }
}

//MARK: - RenderPass
RenderPass* BasicRenderPipeline::defaultRenderPass() {
    return _defaultPass;
}

void BasicRenderPipeline::addRenderPass(std::unique_ptr<RenderPass>&& pass) {
    _renderPassArray.emplace_back(std::move(pass));
    std::sort(_renderPassArray.begin(), _renderPassArray.end(),
              [](const std::unique_ptr<RenderPass>& p1, const std::unique_ptr<RenderPass>& p2){
        return p1->priority - p2->priority;
    });
}

void BasicRenderPipeline::addRenderPass(const std::string& name,
                                        int priority,
                                        MTLRenderPassDescriptor* renderTarget,
                                        Layer mask) {
    auto renderPass = std::make_unique<RenderPass>(name, priority, renderTarget, mask);
    _renderPassArray.emplace_back(std::move(renderPass));
    std::sort(_renderPassArray.begin(), _renderPassArray.end(),
              [](const std::unique_ptr<RenderPass>& p1, const std::unique_ptr<RenderPass>& p2){
        return p1->priority - p2->priority;
    });
}

void BasicRenderPipeline::removeRenderPass(const std::string& name) {
    ssize_t index = -1;
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto& pass = _renderPassArray[i];
        if (pass->name == name) index = i;
    }
    
    if (index != -1) {
        _renderPassArray.erase(_renderPassArray.begin() + index);
    }
}

void BasicRenderPipeline::removeRenderPass(const RenderPass* p) {
    ssize_t index = -1;
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto& pass = _renderPassArray[i];
        if (pass->name == p->name) index = i;
    }
    
    if (index != -1) {
        _renderPassArray.erase(_renderPassArray.begin() + index);
    }
}

RenderPass* BasicRenderPipeline::getRenderPass(const std::string& name) {
    for (size_t i = 0, len = _renderPassArray.size(); i < len; i++) {
        const auto& pass = _renderPassArray[i];
        if (pass->name == name) return pass.get();
    }
    
    return nullptr;
}

//MARK: - Internal Pipeline Method
void BasicRenderPipeline::_drawRenderPass(RenderPass* pass, Camera* camera,
                                          std::optional<TextureCubeFace> cubeFace, int mipLevel) {
    pass->preRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
    
    if (pass->enabled) {
        const auto& engine = camera->engine();
        const auto& scene = camera->scene();
        const auto& background = scene->background;
        auto& rhi = engine->_hardwareRenderer;
        
        // prepare to load render target
        MTLRenderPassDescriptor* renderTarget;
        if (camera->renderTarget() != nullptr) {
            renderTarget = camera->renderTarget();
        } else {
            renderTarget = pass->renderTarget;
        }
        rhi.activeRenderTarget(renderTarget);
        // set clear flag
        const auto& clearFlags = pass->clearFlags != std::nullopt ? pass->clearFlags.value(): camera->clearFlags;
        const auto& color = pass->clearColor != std::nullopt? pass->clearColor.value(): background.solidColor;
        if (clearFlags != CameraClearFlags::None) {
            rhi.clearRenderTarget(clearFlags, color);
        }
        
        // command encoder
        rhi.beginRenderPass(renderTarget, camera, mipLevel);
        if (pass->renderOverride) {
            pass->render(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
        } else {
            _drawElement(_opaqueQueue, pass);
            _drawElement(_alphaTestQueue, pass);
            if (background.mode == BackgroundMode::Sky) {
                _drawSky(background.sky);
            }
            _drawElement(_transparentQueue, pass);
        }
        
        // poseprocess
        
        rhi.endRenderPass();// renderEncoder
    }
    
    pass->postRender(camera, _opaqueQueue, _alphaTestQueue, _transparentQueue);
}

void BasicRenderPipeline::_drawElement(const std::vector<RenderElement>& items, RenderPass* pass) {
    if (items.size() == 0) {
        return;
    }
    
    const auto& engine = _camera->engine();
    const auto& scene = _camera->scene();
    auto& rhi = engine->_hardwareRenderer;
    const auto& sceneData = scene->shaderData;
    const auto& cameraData = _camera->shaderData;
    
    //MARK:- Start Render
    for (size_t i = 0; i < items.size(); i++) {
        const auto& item = items[i];
        const auto& renderPassFlag = item.component->entity()->layer;
        
        if ((renderPassFlag & pass->mask) == 0) {
            continue;
        }
        
        // RenderElement
        auto compileMacros = ShaderMacroCollection();
        const auto& element = item;
        const auto& renderer = element.component;
        auto material = pass->material(element);
        if (material == nullptr) {
            material = element.material;
        }
        auto& rendererData = renderer->shaderData;
        const auto& materialData = material->shaderData;
        
        if (renderer->receiveShadow && shadowCount != 0) {
            rendererData.enableMacro(SHADOW_MAP_COUNT, std::make_pair(shadowCount, MTLDataTypeInt));
        }
        
        // union render global macro and material self macro.
        materialData.mergeMacro(renderer->_globalShaderMacro, compileMacros);
        
        //MARK:- Set Pipeline State
        ShaderProgram* program = material->shader->findShaderProgram(engine, compileMacros);
        if (!program->isValid()) {
            continue;
        }
        
        MTLRenderPipelineDescriptor* descriptor = [[MTLRenderPipelineDescriptor alloc]init];
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh->vertexDescriptor());
        descriptor.vertexFunction = program->vertexShader();
        descriptor.fragmentFunction = program->fragmentShader();
        
        descriptor.colorAttachments[0].pixelFormat = engine->_hardwareRenderer.colorPixelFormat();
        descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
        
        MTLDepthStencilDescriptor* depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc]init];
        material->renderState._apply(engine, descriptor, depthStencilDescriptor);
        rhi.setDepthStencilState(depthStencilDescriptor);
        
        const auto& pipelineState = rhi.resouceCache.request_graphics_pipeline(descriptor);
        rhi.setRenderPipelineState(pipelineState);
        
        //MARK:- Load Resouces
        pipelineState->uploadAll(pipelineState->sceneUniformBlock, sceneData);
        pipelineState->uploadAll(pipelineState->cameraUniformBlock, cameraData);
        pipelineState->uploadAll(pipelineState->rendererUniformBlock, rendererData);
        pipelineState->uploadAll(pipelineState->materialUniformBlock, materialData);
        pipelineState->uploadAll(pipelineState->internalUniformBlock, shaderData);
        
        auto& buffers = element.mesh->_vertexBuffer;
        for (uint32_t index = 0; index < buffers.size(); index++) {
            rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
        }
        rhi.drawPrimitive(element.subMesh);
    }
}

void BasicRenderPipeline::_drawSky(const Sky& sky) {
    const auto& material = sky.material;
    const auto& mesh = sky.mesh;
    if (!material) {
        std::cerr << "The material of sky is not defined." << std::endl;
        return;
    }
    if (!mesh) {
        std::cerr << "The mesh of sky is not defined." << std::endl;
        return;
    }
    
    const auto& engine = _camera->engine();
    auto& rhi = engine->_hardwareRenderer;
    auto& shaderData = material->shaderData;
    
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
    
    auto descriptor = [[MTLRenderPipelineDescriptor alloc]init];
    descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh->vertexDescriptor());
    descriptor.vertexFunction = program->vertexShader();
    descriptor.fragmentFunction = program->fragmentShader();
    
    descriptor.colorAttachments[0].pixelFormat = engine->_hardwareRenderer.colorPixelFormat();
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    auto depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc]init];
    material->renderState._apply(engine, descriptor, depthStencilDescriptor);
    rhi.setDepthStencilState(depthStencilDescriptor);
    
    auto pipelineState = rhi.resouceCache.request_graphics_pipeline(descriptor);
    rhi.setRenderPipelineState(pipelineState);
    
    pipelineState->uploadAll(pipelineState->materialUniformBlock, shaderData);
    
    auto& buffers = mesh->_vertexBuffer;
    for (uint32_t index = 0; index < buffers.size(); index++) {
        rhi.setVertexBuffer(buffers[index]->buffer, 0, index);
    }
    rhi.drawPrimitive(mesh->subMesh(0));
}

void BasicRenderPipeline::_drawShadowMap(RenderContext& context) {
    const auto& engine = _camera->engine();
    auto& rhi = engine->_hardwareRenderer;
    
    const auto& lights = context.scene()->light_manager.visibleLights();
    for (const auto& light : lights) {
        if (light->enableShadow()) {
            id<MTLTexture> texture = nullptr;
            if (shadowCount < shadowMaps.size()) {
                texture = shadowMaps[shadowCount];
            } else {
                texture = rhi.resourceLoader()->buildTexture(shadowMapSize, shadowMapSize,
                                                             MTLPixelFormatDepth32Float);
                shadowMaps.push_back(texture);
            }
            
            MTLRenderPassDescriptor* shadowRenderPassDescriptor = [[MTLRenderPassDescriptor alloc]init];
            shadowRenderPassDescriptor.depthAttachment.texture = texture;
            shadowRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
            shadowRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
            shadowRenderPassDescriptor.depthAttachment.clearDepth = 1;
            rhi.activeRenderTarget(shadowRenderPassDescriptor);
            rhi.beginRenderPass(shadowRenderPassDescriptor, _camera, 0);
            
            MTLDepthStencilDescriptor* depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc]init];
            depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
            depthStencilDescriptor.depthWriteEnabled = true;
            rhi.setDepthStencilState(depthStencilDescriptor);
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
            
            for (const auto& element : opaqueQueue) {
                if (element.component->castShadow) {
                    Shader shader("shadowMap", "vertex_depth", "");
                    auto program = shader.findShaderProgram(engine, element.component->_globalShaderMacro);
                    
                    MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc]init];
                    pipelineDescriptor.vertexFunction = program->vertexShader();
                    pipelineDescriptor.fragmentFunction = NULL;
                    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatInvalid;
                    pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh->vertexDescriptor());
                    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
                    const auto& pipelineState = rhi.resouceCache.request_graphics_pipeline(pipelineDescriptor);
                    rhi.setRenderPipelineState(pipelineState);
                    
                    auto modelMatrix = element.component->entity()->transform->worldMatrix();
                    rhi.setVertexBytes(light->shadow.vp, 11);
                    rhi.setVertexBytes(modelMatrix, 12);
                    
                    auto& buffers = element.mesh->_vertexBuffer;
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

void BasicRenderPipeline::_drawCascadeShadowMap(RenderContext& context) {
    const auto& engine = _camera->engine();
    auto& rhi = engine->_hardwareRenderer;
    
    const auto& lights = context.scene()->light_manager.directLights();
    for (const auto& light : lights) {
        if (light->enableShadow()) {
            id<MTLTexture> texture = nullptr;
            if (shadowCount < shadowMaps.size()) {
                texture = shadowMaps[shadowCount];
            } else {
                texture = rhi.resourceLoader()->buildTexture(shadowMapSize, shadowMapSize,
                                                             MTLPixelFormatDepth32Float);
                shadowMaps.push_back(texture);
            }
            
            MTLRenderPassDescriptor* shadowRenderPassDescriptor = [[MTLRenderPassDescriptor alloc]init];
            shadowRenderPassDescriptor.depthAttachment.texture = texture;
            shadowRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
            shadowRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
            shadowRenderPassDescriptor.depthAttachment.clearDepth = 1;
            rhi.activeRenderTarget(shadowRenderPassDescriptor);
            rhi.beginRenderPass(shadowRenderPassDescriptor, _camera, 0);
            
            MTLDepthStencilDescriptor* depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc]init];
            depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
            depthStencilDescriptor.depthWriteEnabled = true;
            rhi.setDepthStencilState(depthStencilDescriptor);
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
            
            for (const auto& element : opaqueQueue) {
                if (element.component->castShadow) {
                    Shader shader("shadowMap", "vertex_depth", "");
                    auto program = shader.findShaderProgram(engine, element.component->_globalShaderMacro);
                    
                    MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc]init];
                    pipelineDescriptor.vertexFunction = program->vertexShader();
                    pipelineDescriptor.fragmentFunction = NULL;
                    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatInvalid;
                    pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(element.mesh->vertexDescriptor());
                    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
                    const auto& pipelineState = rhi.resouceCache.request_graphics_pipeline(pipelineDescriptor);
                    rhi.setRenderPipelineState(pipelineState);
                    
                    auto modelMatrix = element.component->entity()->transform->worldMatrix();
                    rhi.setVertexBytes(light->shadow.vp, 11);
                    rhi.setVertexBytes(modelMatrix, 12);
                    
                    auto& buffers = element.mesh->_vertexBuffer;
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

void BasicRenderPipeline::_updateCascades(DirectLight* light) {
    std::array<float, SHADOW_MAP_CASCADE_COUNT> cascadeSplits{};

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
        math::Float3(-1.0f,  1.0f, -1.0f),
        math::Float3( 1.0f,  1.0f, -1.0f),
        math::Float3( 1.0f, -1.0f, -1.0f),
        math::Float3(-1.0f, -1.0f, -1.0f),
        math::Float3(-1.0f,  1.0f,  1.0f),
        math::Float3( 1.0f,  1.0f,  1.0f),
        math::Float3( 1.0f, -1.0f,  1.0f),
        math::Float3(-1.0f, -1.0f,  1.0f),
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

        // Get frustum center
        Float3 frustumCenter = Float3(0.0f);
        for (uint32_t i = 0; i < 8; i++) {
            frustumCenter = frustumCenter + _frustumCorners[i];
        }
        frustumCenter = frustumCenter / 8.0f;
        
        float radius = 0.0f;
        for (uint32_t i = 0; i < 8; i++) {
            float distance = Length(_frustumCorners[i] - frustumCenter);
            radius = std::max<float>(radius, distance);
        }
        radius = std::ceil(radius * 16.0f) / 16.0f;
        
        Float3 maxExtents = Float3(radius);
        Float3 minExtents = -maxExtents;
        
        Float3 lightDir = light->direction();
        Matrix lightViewMatrix = Matrix::lookAt(frustumCenter - lightDir * -minExtents.z, frustumCenter, Float3(0.0f, 1.0f, 0.0f));
        Matrix lightOrthoMatrix = Matrix::ortho(minExtents.x, maxExtents.x, minExtents.y, maxExtents.y, 0.0f, maxExtents.z - minExtents.z);

        // Store split distance and matrix in cascade
        shadowDatas[shadowCount].cascadeSplits[i] = (_camera->nearClipPlane() + splitDist * clipRange) * -1.0f;
        auto vp = lightOrthoMatrix * lightViewMatrix;
        shadowDatas[shadowCount].vp[i].columns[0] = simd_make_float4(vp.elements[0], vp.elements[1], vp.elements[2], vp.elements[3]);
        shadowDatas[shadowCount].vp[i].columns[1] = simd_make_float4(vp.elements[4], vp.elements[5], vp.elements[6], vp.elements[7]);
        shadowDatas[shadowCount].vp[i].columns[2] = simd_make_float4(vp.elements[8], vp.elements[9], vp.elements[10], vp.elements[11]);
        shadowDatas[shadowCount].vp[i].columns[3] = simd_make_float4(vp.elements[12], vp.elements[13], vp.elements[14], vp.elements[15]);
        
        lastSplitDist = cascadeSplits[i];
    }
}

}
