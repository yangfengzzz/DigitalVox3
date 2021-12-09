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
    
}

math::Float3 ParticleRenderer::position() {
    return _position;
}

void ParticleRenderer::setPosition(const math::Float3& value) {
    
}

math::Float3 ParticleRenderer::positionRandomness() {
    return _positionRandomness;
}

void ParticleRenderer::setPositionRandomness(const math::Float3& value) {
    
}

const std::vector<math::Float3>& ParticleRenderer::positionArray() const {
    return _positionArray;
}

void ParticleRenderer::setPositionArray(const std::vector<math::Float3>& value) {
    
}

math::Float3 ParticleRenderer::velocity() {
    return _velocity;
}

void ParticleRenderer::setVelocity(const math::Float3& value) {
    
}

math::Float3 ParticleRenderer::velocityRandomness() {
    return _velocityRandomness;
}

void ParticleRenderer::setVelocityRandomness(const math::Float3& value) {
    
}

math::Float3 ParticleRenderer::acceleration() {
    return _acceleration;
}

void ParticleRenderer::setAcceleration(const math::Float3& value) {
    
}

math::Float3 ParticleRenderer::accelerationRandomness() {
    return _accelerationRandomness;
}

void ParticleRenderer::setAccelerationRandomness(const math::Float3& value) {
    
}

math::Color ParticleRenderer::color() {
    return _color;
}

void ParticleRenderer::setColor(const math::Color& value) {
    
}

float ParticleRenderer::colorRandomness() {
    return _colorRandomness;
}

void ParticleRenderer::setColorRandomness(float value) {
    
}

float ParticleRenderer::size() {
    return _size;
}

void ParticleRenderer::setSize(float value) {
    
}

float ParticleRenderer::sizeRandomness() {
    return _sizeRandomness;
}

void ParticleRenderer::setSizeRandomness(float value) {
    
}

float ParticleRenderer::alpha() {
    return _alpha;
}

void ParticleRenderer::setAlpha(float value) {
    
}

float ParticleRenderer::alphaRandomness() {
    return _alphaRandomness;
}

void ParticleRenderer::setAlphaRandomness(float value) {
    
}

float ParticleRenderer::angle() {
    return _startAngle;
}

void ParticleRenderer::setAngle(float value) {
    
}

float ParticleRenderer::angleRandomness() {
    return _startAngleRandomness;
}

void ParticleRenderer::setAngleRandomness(float value) {
    
}

float ParticleRenderer::rotateVelocity() {
    return _rotateVelocity;
}

void ParticleRenderer::setRotateVelocity(float value) {
    
}

float ParticleRenderer::rotateVelocityRandomness() {
    return _rotateVelocityRandomness;
}

void ParticleRenderer::setRotateVelocityRandomness(float value) {
    
}

float ParticleRenderer::lifetime() {
    return _lifetime;
}

void ParticleRenderer::setLifetime(float value) {
    
}

float ParticleRenderer::startTimeRandomness() {
    return _startTimeRandomness;
}

void ParticleRenderer::setStartTimeRandomness(float value) {
    
}

float ParticleRenderer::scale() {
    return _scale;
}

void ParticleRenderer::setScale(float value) {
    
}

size_t ParticleRenderer::maxCount() {
    return _maxCount;
}

void ParticleRenderer::setMaxCount(size_t value) {
    
}

bool ParticleRenderer::isOnce() {
    return _isOnce;
}

void ParticleRenderer::setIsOnce(bool value) {
    
}

bool ParticleRenderer::isRotateToVelocity() {
    return _isRotateToVelocity;
}

void ParticleRenderer::setIsRotateToVelocity(bool value) {
    
}

bool ParticleRenderer::isUseOriginColor() {
    return _isUseOriginColor;
}

void ParticleRenderer::setIsUseOriginColor(bool value) {
    
}

bool ParticleRenderer::isScaleByLifetime() {
    return _isScaleByLifetime;
}

void ParticleRenderer::setIsScaleByLifetime(bool value) {
    
}

bool ParticleRenderer::is2d() {
    return _is2d;
}

void ParticleRenderer::setIs2d(bool value) {
    
}

bool ParticleRenderer::isFadeIn() {
    return _isFadeIn;
}

void ParticleRenderer::setIsFadeIn(bool value) {
    
}

bool ParticleRenderer::isFadeOut() {
    return _isFadeOut;
}

void ParticleRenderer::setIsFadeOut(bool value) {
    
}

bool ParticleRenderer::playOnEnable() {
    return _playOnEnable;
}

void ParticleRenderer::setPlayOnEnable(bool value) {
    
}

ParticleRendererBlendMode::Enum ParticleRenderer::blendMode() {
    return _blendMode;
}

void ParticleRenderer::setBlendMode(ParticleRendererBlendMode::Enum value) {
    
}

void ParticleRenderer::update(float deltaTime) {
    
}

void ParticleRenderer::_onEnable() {
    
}

void ParticleRenderer::start() {
    
}

void ParticleRenderer::stop() {
    
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
