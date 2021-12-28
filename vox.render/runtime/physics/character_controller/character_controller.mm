//
//  CharacterController.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#include "character_controller.h"
#include "../../engine.h"

namespace vox {
namespace physics {
CharacterController::CharacterController(Entity *entity) :
Component(entity) {
}

PxControllerCollisionFlags CharacterController::move(const math::Float3 &disp, float minDist, float elapsedTime) {
    return _nativeController->move(PxVec3(disp.x, disp.y, disp.z), minDist, elapsedTime, PxControllerFilters());
}

bool CharacterController::setPosition(const math::Float3 &position) {
    return _nativeController->setPosition(PxExtendedVec3(position.x, position.y, position.z));
}

math::Float3 CharacterController::position() const {
    auto pose = _nativeController->getPosition();
    return math::Float3(pose.x, pose.y, pose.z);
}

bool CharacterController::setFootPosition(const math::Float3 &position) {
    return _nativeController->setFootPosition(PxExtendedVec3(position.x, position.y, position.z));
}

math::Float3 CharacterController::footPosition() const {
    auto pose = _nativeController->getFootPosition();
    return math::Float3(pose.x, pose.y, pose.z);
}

void CharacterController::setStepOffset(const float offset) {
    _nativeController->setStepOffset(offset);
}

float CharacterController::stepOffset() const {
    return _nativeController->getStepOffset();
}

void CharacterController::setNonWalkableMode(PxControllerNonWalkableMode::Enum flag) {
    _nativeController->setNonWalkableMode(flag);
}

PxControllerNonWalkableMode::Enum CharacterController::nonWalkableMode() const {
    return _nativeController->getNonWalkableMode();
}

float CharacterController::contactOffset() const {
    return _nativeController->getContactOffset();
}

void CharacterController::setContactOffset(float offset) {
    _nativeController->setContactOffset(offset);
}

math::Float3 CharacterController::upDirection() const {
    auto dir = _nativeController->getUpDirection();
    return math::Float3(dir.x, dir.y, dir.z);
}

void CharacterController::setUpDirection(const math::Float3 &up) {
    _nativeController->setUpDirection(PxVec3(up.x, up.y, up.z));
}

float CharacterController::slopeLimit() const {
    return _nativeController->getSlopeLimit();
}

void CharacterController::setSlopeLimit(float slopeLimit) {
    _nativeController->setSlopeLimit(slopeLimit);
}

void CharacterController::invalidateCache() {
    _nativeController->invalidateCache();
}

void CharacterController::state(PxControllerState &state) const {
    _nativeController->getState(state);
}

void CharacterController::stats(PxControllerStats &stats) const {
    _nativeController->getStats(stats);
}

void CharacterController::resize(float height) {
    _nativeController->resize(height);
}

void CharacterController::_onLateUpdate() {
    entity()->transform->setWorldPosition(position());
}

void CharacterController::_onEnable() {
    engine()->_physicsManager._addCharacterController(this);
}

void CharacterController::_onDisable() {
    engine()->_physicsManager._removeCharacterController(this);
}

}
}
