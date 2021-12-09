//
//  particle_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#include "particle_renderer.h"
#include "../material/material.h"

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
    return nullptr;
}

MeshPtr ParticleRenderer::_createMesh() {
    return nullptr;
}

void ParticleRenderer::_updateBuffer() {
    
}

void ParticleRenderer::_updateSingleBuffer(size_t i) {
    
}

void ParticleRenderer::_updateSingleUv(size_t i, size_t k0, size_t k1, size_t k2, size_t k3) {
    
}


}
