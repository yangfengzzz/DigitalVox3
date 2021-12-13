//
//  particle_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#include "particle_renderer.h"
#include "../material/material.h"
#include "../mesh/buffer_mesh.h"
#include "../entity.h"
#include "../engine.h"

namespace vox {
ParticleRenderer::ParticleRenderer(Entity* entity):
Renderer(entity) {
    setMaterial(_createMaterial());
}

id<MTLTexture> ParticleRenderer::texture() {
    return std::any_cast<id<MTLTexture>>(getMaterial()->shaderData.getData("u_texture"));
}

void ParticleRenderer::setTexture(id<MTLTexture> texture) {
    if (texture) {
        shaderData.enableMacro(HAS_PARTICLE_TEXTURE);
        getMaterial()->shaderData.setData("u_texture", texture);
    } else {
        shaderData.disableMacro(HAS_PARTICLE_TEXTURE);
    }
}

math::Float3 ParticleRenderer::position() {
    return _position;
}

void ParticleRenderer::setPosition(const math::Float3& value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Position;
    _position = value;
}

math::Float3 ParticleRenderer::positionRandomness() {
    return _positionRandomness;
}

void ParticleRenderer::setPositionRandomness(const math::Float3& value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Position;
    _positionRandomness = value;
}

const std::vector<math::Float3>& ParticleRenderer::positionArray() const {
    return _positionArray;
}

void ParticleRenderer::setPositionArray(const std::vector<math::Float3>& value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Position;
    _positionArray = value;
}

math::Float3 ParticleRenderer::velocity() {
    return _velocity;
}

void ParticleRenderer::setVelocity(const math::Float3& value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Velocity;
    _velocity = value;
}

math::Float3 ParticleRenderer::velocityRandomness() {
    return _velocityRandomness;
}

void ParticleRenderer::setVelocityRandomness(const math::Float3& value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Velocity;
    _velocityRandomness = value;
}

math::Float3 ParticleRenderer::acceleration() {
    return _acceleration;
}

void ParticleRenderer::setAcceleration(const math::Float3& value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Acceleration;
    _acceleration = value;
}

math::Float3 ParticleRenderer::accelerationRandomness() {
    return _accelerationRandomness;
}

void ParticleRenderer::setAccelerationRandomness(const math::Float3& value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Acceleration;
    _accelerationRandomness = value;
}

math::Color ParticleRenderer::color() {
    return _color;
}

void ParticleRenderer::setColor(const math::Color& value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Color;
    _color = value;
}

float ParticleRenderer::colorRandomness() {
    return _colorRandomness;
}

void ParticleRenderer::setColorRandomness(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Color;
    _colorRandomness = value;
}

float ParticleRenderer::size() {
    return _size;
}

void ParticleRenderer::setSize(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Size;
    _size = value;
}

float ParticleRenderer::sizeRandomness() {
    return _sizeRandomness;
}

void ParticleRenderer::setSizeRandomness(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Size;
    _sizeRandomness = value;
}

float ParticleRenderer::alpha() {
    return _alpha;
}

void ParticleRenderer::setAlpha(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Alpha;
    _alpha = value;
}

float ParticleRenderer::alphaRandomness() {
    return _alphaRandomness;
}

void ParticleRenderer::setAlphaRandomness(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Alpha;
    _alphaRandomness = value;
}

float ParticleRenderer::angle() {
    return _startAngle;
}

void ParticleRenderer::setAngle(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::StartAngle;
    _startAngle = value;
}

float ParticleRenderer::angleRandomness() {
    return _startAngleRandomness;
}

void ParticleRenderer::setAngleRandomness(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::StartAngle;
    _startAngleRandomness = value;
}

float ParticleRenderer::rotateVelocity() {
    return _rotateVelocity;
}

void ParticleRenderer::setRotateVelocity(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::RotateVelocity;
    _rotateVelocity = value;
}

float ParticleRenderer::rotateVelocityRandomness() {
    return _rotateVelocityRandomness;
}

void ParticleRenderer::setRotateVelocityRandomness(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::RotateVelocity;
    _rotateVelocityRandomness = value;
}

float ParticleRenderer::lifetime() {
    return _lifetime;
}

void ParticleRenderer::setLifetime(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::LifeTime;
    _lifetime = value;
    _onceTime = 0;
}

float ParticleRenderer::startTimeRandomness() {
    return _startTimeRandomness;
}

void ParticleRenderer::setStartTimeRandomness(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::StartTime;
    _startTimeRandomness = value;
    _onceTime = 0;
}

float ParticleRenderer::scale() {
    return _scale;
}

void ParticleRenderer::setScale(float value) {
    _updateDirtyFlag |= DirtyFlagType::Enum::Scale;
    _scale = value;
}

size_t ParticleRenderer::maxCount() {
    return _maxCount;
}

void ParticleRenderer::setMaxCount(size_t value) {
    _isStart = false;
    _isInit = false;
    _maxCount = value;
    _updateDirtyFlag = DirtyFlagType::Enum::Everything;
    // mesh = _createMesh();
    
    _updateBuffer();
    
    _isInit = true;
    shaderData.setData("u_time", 0.f);
}

bool ParticleRenderer::isOnce() {
    return _isOnce;
}

void ParticleRenderer::setIsOnce(bool value) {
    _time = 0;
    shaderData.setData("u_once", value ? 1.f : 0.f);
    _isOnce = value;
}

bool ParticleRenderer::isRotateToVelocity() {
    return _isRotateToVelocity;
}

void ParticleRenderer::setIsRotateToVelocity(bool value) {
    if (value) {
        shaderData.enableMacro(NEED_ROTATE_TO_VELOCITY);
    } else {
        shaderData.disableMacro(NEED_ROTATE_TO_VELOCITY);
    }
    
    _isRotateToVelocity = value;
}

bool ParticleRenderer::isUseOriginColor() {
    return _isUseOriginColor;
}

void ParticleRenderer::setIsUseOriginColor(bool value) {
    if (value) {
        shaderData.enableMacro(NEED_USE_ORIGIN_COLOR);
    } else {
        shaderData.disableMacro(NEED_USE_ORIGIN_COLOR);
    }
    
    _isUseOriginColor = value;
}

bool ParticleRenderer::isScaleByLifetime() {
    return _isScaleByLifetime;
}

void ParticleRenderer::setIsScaleByLifetime(bool value) {
    if (value) {
        shaderData.enableMacro(NEED_SCALE_BY_LIFE_TIME);
    } else {
        shaderData.disableMacro(NEED_SCALE_BY_LIFE_TIME);
    }
    
    _isScaleByLifetime = value;
}

bool ParticleRenderer::is2d() {
    return _is2d;
}

void ParticleRenderer::setIs2d(bool value) {
    if (value) {
        shaderData.enableMacro(IS_2D);
    } else {
        shaderData.disableMacro(IS_2D);
        getMaterial()->renderState.rasterState.cullMode = MTLCullModeNone;
    }
    
    _is2d = value;
}

bool ParticleRenderer::isFadeIn() {
    return _isFadeIn;
}

void ParticleRenderer::setIsFadeIn(bool value) {
    if (value) {
        shaderData.enableMacro(NEED_FADE_IN);
    } else {
        shaderData.disableMacro(NEED_FADE_IN);
    }
    
    _isFadeIn = value;
}

bool ParticleRenderer::isFadeOut() {
    return _isFadeOut;
}

void ParticleRenderer::setIsFadeOut(bool value) {
    if (value) {
        shaderData.enableMacro(NEED_FADE_OUT);
    } else {
        shaderData.disableMacro(NEED_FADE_OUT);
    }
    
    _isFadeOut = value;
}

bool ParticleRenderer::playOnEnable() {
    return _playOnEnable;
}

void ParticleRenderer::setPlayOnEnable(bool value) {
    _playOnEnable = value;
    
    if (value) {
        start();
    } else {
        stop();
    }
}

ParticleRendererBlendMode::Enum ParticleRenderer::blendMode() {
    return _blendMode;
}

void ParticleRenderer::setBlendMode(ParticleRendererBlendMode::Enum value) {
    auto& blendState = getMaterial()->renderState.blendState;
    auto& target = blendState.targetBlendState;
    
    if (value == ParticleRendererBlendMode::Enum::Transparent) {
        target.enabled = true;
        target.sourceColorBlendFactor = MTLBlendFactorSourceAlpha;
        target.destinationColorBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
        target.sourceAlphaBlendFactor = MTLBlendFactorOne;
        target.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    } else if (value == ParticleRendererBlendMode::Enum::Additive) {
        target.enabled = true;
        target.sourceColorBlendFactor = MTLBlendFactorSourceAlpha;
        target.destinationColorBlendFactor = MTLBlendFactorOne;
        target.sourceAlphaBlendFactor = MTLBlendFactorOne;
        target.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    }
    
    _blendMode = value;
}

void ParticleRenderer::update(float deltaTime) {
    if (!_isInit || !_isStart) {
        return;
    }
    
    // Stop after play once
    if (_isOnce && _time > _onceTime) {
        return stop();
    }
    
    if (_updateDirtyFlag) {
        _updateBuffer();
        _updateDirtyFlag = 0;
    }
    
    _time += deltaTime / 1000;
    shaderData.setData("u_time", _time);
}

void ParticleRenderer::_onEnable() {
    if (_playOnEnable) {
        start();
    }
}

void ParticleRenderer::start() {
    _isStart = true;
    _time = 0;
}

void ParticleRenderer::stop() {
    _isStart = false;
}

MaterialPtr ParticleRenderer::_createMaterial() {
    auto material = std::make_shared<Material>(engine(), Shader::find("particle-shader"));
    auto& renderState = material->renderState;
    auto& target = renderState.blendState.targetBlendState;
    
    target.enabled = true;
    target.sourceColorBlendFactor = MTLBlendFactorSourceAlpha;
    target.destinationColorBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    target.sourceAlphaBlendFactor = MTLBlendFactorOne;
    target.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    
    renderState.depthState.writeEnabled = false;
    
    material->renderQueueType = RenderQueueType::Enum::Transparent;
    
    setIsUseOriginColor(true);
    setIs2d(true);
    setIsFadeOut(true);
    
    return material;
}

MeshPtr ParticleRenderer::_createMesh() {
    auto mesh = std::make_shared<BufferMesh>(_entity->engine(), "particleMesh");
    const auto vertexStride = 96;
    const auto vertexCount = _maxCount * 4;
    const auto vertexFloatCount = vertexCount * vertexStride;
    auto vertices = std::vector<float>(vertexFloatCount);
    auto indices = std::vector<uint32_t>(6 * _maxCount);
    
    for (uint32_t i = 0, idx = 0; i < _maxCount; ++i) {
        uint32_t startIndex = i * 4;
        indices[idx++] = startIndex;
        indices[idx++] = startIndex + 1;
        indices[idx++] = startIndex + 2;
        indices[idx++] = startIndex;
        indices[idx++] = startIndex + 2;
        indices[idx++] = startIndex + 3;
    }
    
    MDLVertexDescriptor* descriptor = [[MDLVertexDescriptor alloc]init];
    descriptor.attributes[0] =
    [[MDLVertexAttribute alloc]initWithName:@"a_position"
                                     format:MDLVertexFormatFloat3
                                     offset:0 bufferIndex:0];
    descriptor.attributes[1] =
    [[MDLVertexAttribute alloc]initWithName:@"a_velocity"
                                     format:MDLVertexFormatFloat3
                                     offset:12 bufferIndex:0];
    descriptor.attributes[2] =
    [[MDLVertexAttribute alloc]initWithName:@"a_acceleration"
                                     format:MDLVertexFormatFloat3
                                     offset:24 bufferIndex:0];
    descriptor.attributes[3] =
    [[MDLVertexAttribute alloc]initWithName:@"a_color"
                                     format:MDLVertexFormatFloat4
                                     offset:36 bufferIndex:0];
    descriptor.attributes[4] =
    [[MDLVertexAttribute alloc]initWithName:@"a_lifeAndSize"
                                     format:MDLVertexFormatFloat4
                                     offset:52 bufferIndex:0];
    descriptor.attributes[5] =
    [[MDLVertexAttribute alloc]initWithName:@"a_rotation"
                                     format:MDLVertexFormatFloat2
                                     offset:68 bufferIndex:0];
    descriptor.attributes[6] =
    [[MDLVertexAttribute alloc]initWithName:@"a_uv"
                                     format:MDLVertexFormatFloat3
                                     offset:76 bufferIndex:0];
    descriptor.attributes[7] =
    [[MDLVertexAttribute alloc]initWithName:@"a_normalizedUv"
                                     format:MDLVertexFormatFloat2
                                     offset:88 bufferIndex:0];
    
    auto vertexBuffer = [_engine->_hardwareRenderer.device newBufferWithLength:vertexFloatCount * 4
                                                                       options:MTLResourceStorageModeShared];
    auto indexBuffer = [_engine->_hardwareRenderer.device newBufferWithBytes:indices.data()
                                                                      length:indices.size() * sizeof(uint32_t)
                                                                     options:MTLResourceStorageModeShared];
    
    mesh->setVertexDescriptor(descriptor);
    mesh->setVertexBufferBinding(vertexBuffer, vertexStride);
    mesh->addSubMesh(MeshBuffer(indexBuffer, indices.size(), MDLMeshBufferTypeIndex), MTLIndexTypeUInt32);

    _vertexBuffer = vertexBuffer;
    _vertexStride = vertexStride / 4;
    _vertices = vertices;
    return mesh;
}

void ParticleRenderer::_updateBuffer() {
    for (size_t x = 0; x < _maxCount; x++) {
        _updateSingleBuffer(x);
    }
    
    memcpy([_vertexBuffer contents], _vertices.data(), sizeof(float) * _vertices.size());
}

void ParticleRenderer::_updateSingleBuffer(size_t i) {
    
}

void ParticleRenderer::_updateSingleUv(size_t i, size_t k0, size_t k1, size_t k2, size_t k3) {
    
}


}
