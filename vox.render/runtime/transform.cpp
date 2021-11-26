//
//  transform.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "transform.h"
#include "entity.h"

namespace vox {
Transform::Transform(Entity *entity) : Component(entity) {
}

Float3 Transform::position() {
    return _position;
}

void Transform::setPosition(const Float3 &value) {
    _position = value;
    _setDirtyFlagTrue(TransformFlag::LocalMatrix);
    _updateWorldPositionFlag();
}

Float3 Transform::worldPosition() {
    if (_isContainDirtyFlag(TransformFlag::WorldPosition)) {
        if (_getParentTransform()) {
            _worldPosition = worldMatrix().getTranslation();
        } else {
            _worldPosition = _position;
        }
        _setDirtyFlagFalse(TransformFlag::WorldPosition);
    }
    return _worldPosition;
}

void Transform::setWorldPosition(const Float3 &value) {
    _worldPosition = value;
    const auto parent = _getParentTransform();
    if (parent) {
        const auto _tempMat41 = invert(parent->worldMatrix());
        _position = transformCoordinate(value, _tempMat41);
    } else {
        _position = value;
    }
    setPosition(_position);
    _setDirtyFlagFalse(TransformFlag::WorldPosition);
}

Float3 Transform::rotation() {
    if (_isContainDirtyFlag(TransformFlag::LocalEuler)) {
        _rotation = ToEuler(_rotationQuaternion);
        _rotation = _rotation * kRadianToDegree; // radians to degrees
        
        _setDirtyFlagFalse(TransformFlag::LocalEuler);
    }
    return _rotation;
}

void Transform::setRotation(const Float3 &value) {
    _rotation = value;
    _setDirtyFlagTrue(TransformFlag::LocalMatrix | TransformFlag::LocalQuat);
    _setDirtyFlagFalse(TransformFlag::LocalEuler);
    _updateWorldRotationFlag();
}

Float3 Transform::worldRotation() {
    if (_isContainDirtyFlag(TransformFlag::WorldEuler)) {
        _worldRotation = ToEuler(worldRotationQuaternion());
        _worldRotation = _worldRotation * kRadianToDegree; // Radian to angle
        _setDirtyFlagFalse(TransformFlag::WorldEuler);
    }
    return _worldRotation;
}

void Transform::setWorldRotation(const Float3 &value) {
    _worldRotation = value;
    _worldRotationQuaternion = Quaternion::FromEuler(degreeToRadian(value.y), degreeToRadian(value.x), degreeToRadian(value.z));
    setWorldRotationQuaternion(_worldRotationQuaternion);
    _setDirtyFlagFalse(TransformFlag::WorldEuler);
}

Quaternion Transform::rotationQuaternion() {
    if (_isContainDirtyFlag(TransformFlag::LocalQuat)) {
        _rotationQuaternion = Quaternion::FromEuler(degreeToRadian(_rotation.y), degreeToRadian(_rotation.x), degreeToRadian(_rotation.z));
        _setDirtyFlagFalse(TransformFlag::LocalQuat);
    }
    return _rotationQuaternion;
}

void Transform::setRotationQuaternion(const Quaternion &value) {
    _rotationQuaternion = value;
    _setDirtyFlagTrue(TransformFlag::LocalMatrix | TransformFlag::LocalEuler);
    _setDirtyFlagFalse(TransformFlag::LocalQuat);
    _updateWorldRotationFlag();
}

Quaternion Transform::worldRotationQuaternion() {
    if (_isContainDirtyFlag(TransformFlag::WorldQuat)) {
        const auto parent = _getParentTransform();
        if (parent) {
            _worldRotationQuaternion = parent->worldRotationQuaternion() * rotationQuaternion();
        } else {
            _worldRotationQuaternion = rotationQuaternion();
        }
        _setDirtyFlagFalse(TransformFlag::WorldQuat);
    }
    return _worldRotationQuaternion;
}

void Transform::setWorldRotationQuaternion(const Quaternion &value) {
    _worldRotationQuaternion = value;
    const auto parent = _getParentTransform();
    if (parent) {
        auto _tempQuat0 = invert(parent->worldRotationQuaternion());
        _rotationQuaternion = value * _tempQuat0;
    } else {
        _rotationQuaternion = value;
    }
    setRotationQuaternion(_rotationQuaternion);
    _setDirtyFlagFalse(TransformFlag::WorldQuat);
}

Float3 Transform::scale() {
    return _scale;
}

void Transform::setScale(const Float3 &value) {
    _scale = value;
    _setDirtyFlagTrue(TransformFlag::LocalMatrix);
    _updateWorldScaleFlag();
}

Float3 Transform::lossyWorldScale() {
    if (_isContainDirtyFlag(TransformFlag::WorldScale)) {
        if (_getParentTransform()) {
            const auto scaleMat = _getScaleMatrix();
            const auto &e = scaleMat.elements;
            _lossyWorldScale = Float3(e[0], e[4], e[8]);
        } else {
            _lossyWorldScale = _scale;
        }
        _setDirtyFlagFalse(TransformFlag::WorldScale);
    }
    return _lossyWorldScale;
}

Matrix Transform::localMatrix() {
    if (_isContainDirtyFlag(TransformFlag::LocalMatrix)) {
        _localMatrix = Matrix::affineTransformation(_scale, rotationQuaternion(), _position);
        _setDirtyFlagFalse(TransformFlag::LocalMatrix);
    }
    return _localMatrix;
}

void Transform::setLocalMatrix(const Matrix &value) {
    _localMatrix = value;
    _localMatrix.decompose(_position, _rotationQuaternion, _scale);
    _setDirtyFlagTrue(TransformFlag::LocalEuler);
    _setDirtyFlagFalse(TransformFlag::LocalMatrix);
    _updateAllWorldFlag();
}

Matrix Transform::worldMatrix() {
    if (_isContainDirtyFlag(TransformFlag::WorldMatrix)) {
        const auto parent = _getParentTransform();
        if (parent) {
            _worldMatrix = parent->worldMatrix() * localMatrix();
        } else {
            _worldMatrix = localMatrix();
        }
        _setDirtyFlagFalse(TransformFlag::WorldMatrix);
    }
    return _worldMatrix;
}

void Transform::setWorldMatrix(const Matrix &value) {
    _worldMatrix = value;
    const auto parent = _getParentTransform();
    if (parent) {
        auto _tempMat42 = invert(parent->worldMatrix());
        _localMatrix = value * _tempMat42;
    } else {
        _localMatrix = value;
    }
    setLocalMatrix(_localMatrix);
    _setDirtyFlagFalse(TransformFlag::WorldMatrix);
}

void Transform::setPosition(float x, float y, float z) {
    _position = Float3(x, y, z);
    setPosition(_position);
}

void Transform::setRotation(float x, float y, float z) {
    _rotation = Float3(x, y, z);
    setRotation(_rotation);
}

void Transform::setRotationQuaternion(float x, float y, float z, float w) {
    _rotationQuaternion = Quaternion(x, y, z, w);
    setRotationQuaternion(_rotationQuaternion);
}

void Transform::setScale(float x, float y, float z) {
    _scale = Float3(x, y, z);
    setScale(_scale);
}

void Transform::setWorldPosition(float x, float y, float z) {
    _worldPosition = Float3(x, y, z);
    setWorldPosition(_worldPosition);
}

void Transform::setWorldRotation(float x, float y, float z) {
    _worldRotation = Float3(x, y, z);
    setWorldRotation(_worldRotation);
}

void Transform::setWorldRotationQuaternion(float x, float y, float z, float w) {
    _worldRotationQuaternion = Quaternion(x, y, z, w);
    setWorldRotationQuaternion(_worldRotationQuaternion);
}

Float3 Transform::worldForward() {
    const auto &e = worldMatrix().elements;
    auto forward = Float3(-e[8], -e[9], -e[10]);
    return Normalize(forward);
}

Float3 Transform::getWorldRight() {
    const auto &e = worldMatrix().elements;
    auto right = Float3(e[0], e[1], e[2]);
    return Normalize(right);
}

Float3 Transform::getWorldUp() {
    const auto &e = worldMatrix().elements;
    auto up = Float3(e[4], e[5], e[6]);
    return Normalize(up);
}

void Transform::translate(const Float3 &translation, bool relativeToLocal) {
    _translate(translation, relativeToLocal);
}

void Transform::translate(float x, float y, float z, bool relativeToLocal) {
    Float3 translate = Float3(x, y, z);
    _translate(translate, relativeToLocal);
}

void Transform::rotate(const Float3 &rotation, bool relativeToLocal) {
    _rotateXYZ(rotation.x, rotation.y, rotation.z, relativeToLocal);
}

void Transform::rotate(float x, float y, float z, bool relativeToLocal) {
    _rotateXYZ(x, y, z, relativeToLocal);
}

void Transform::rotateByAxis(const Float3 &axis, float angle, bool relativeToLocal) {
    const auto rad = angle * kNormalizationToleranceSq;
    const auto _tempQuat0 = Quaternion::FromAxisAngle(axis, rad);
    _rotateByQuat(_tempQuat0, relativeToLocal);
}

void Transform::lookAt(const Float3 &worldPosition, const Float3 &worldUp) {
    const auto position = this->worldPosition();
    const auto EPSILON = kNormalizationToleranceSq;
    if (std::abs(position.x - worldPosition.x) < EPSILON &&
        std::abs(position.y - worldPosition.y) < EPSILON &&
        std::abs(position.z - worldPosition.z) < EPSILON) {
        return;
    }
    Matrix rotMat = Matrix::lookAt(position, worldPosition, worldUp);
    auto worldRotationQuaternion = rotMat.getRotation();
    worldRotationQuaternion = invert(worldRotationQuaternion);
    setWorldRotationQuaternion(worldRotationQuaternion);
}

std::unique_ptr<UpdateFlag> Transform::registerWorldChangeFlag() {
    return _updateFlagManager.registration();
}

void Transform::_parentChange() {
    _isParentDirty = true;
    _updateAllWorldFlag();
}

void Transform::_updateWorldPositionFlag() {
    if (!_isContainDirtyFlags(TransformFlag::WmWp)) {
        _worldAssociatedChange(TransformFlag::WmWp);
        const auto &nodeChildren = _entity->_children;
        for (size_t i = 0, n = nodeChildren.size(); i < n; i++) {
            nodeChildren[i]->transform->_updateWorldPositionFlag();
        }
    }
}

void Transform::_updateWorldRotationFlag() {
    if (!_isContainDirtyFlags(TransformFlag::WmWeWq)) {
        _worldAssociatedChange(TransformFlag::WmWeWq);
        const auto &nodeChildren = _entity->_children;
        for (size_t i = 0, n = nodeChildren.size(); i < n; i++) {
            // Rotation update of parent entity will trigger world position and rotation update of all child entity.
            nodeChildren[i]->transform->_updateWorldPositionAndRotationFlag();
        }
    }
}

void Transform::_updateWorldPositionAndRotationFlag() {
    if (!_isContainDirtyFlags(TransformFlag::WmWpWeWq)) {
        _worldAssociatedChange(TransformFlag::WmWpWeWq);
        const auto &nodeChildren = _entity->_children;
        for (size_t i = 0, n = nodeChildren.size(); i < n; i++) {
            nodeChildren[i]->transform->_updateWorldPositionAndRotationFlag();
        }
    }
}

void Transform::_updateWorldScaleFlag() {
    if (!_isContainDirtyFlags(TransformFlag::WmWs)) {
        _worldAssociatedChange(TransformFlag::WmWs);
        const auto &nodeChildren = _entity->_children;
        for (size_t i = 0, n = nodeChildren.size(); i < n; i++) {
            nodeChildren[i]->transform->_updateWorldPositionAndScaleFlag();
        }
    }
}

void Transform::_updateWorldPositionAndScaleFlag() {
    if (!_isContainDirtyFlags(TransformFlag::WmWpWs)) {
        _worldAssociatedChange(TransformFlag::WmWpWs);
        const auto &nodeChildren = _entity->_children;
        for (size_t i = 0, n = nodeChildren.size(); i < n; i++) {
            nodeChildren[i]->transform->_updateWorldPositionAndScaleFlag();
        }
    }
}

void Transform::_updateAllWorldFlag() {
    if (!_isContainDirtyFlags(TransformFlag::WmWpWeWqWs)) {
        _worldAssociatedChange(TransformFlag::WmWpWeWqWs);
        const auto &nodeChildren = _entity->_children;
        for (size_t i = 0, n = nodeChildren.size(); i < n; i++) {
            nodeChildren[i]->transform->_updateAllWorldFlag();
        }
    }
}

Transform *Transform::_getParentTransform() {
    if (!_isParentDirty) {
        return _parentTransformCache;
    }
    Transform *parentCache = nullptr;
    auto parent = _entity->parent();
    while (parent) {
        const auto &transform = parent->transform;
        if (transform) {
            parentCache = transform;
            break;
        } else {
            parent = parent->parent();
        }
    }
    _parentTransformCache = parentCache;
    _isParentDirty = false;
    return parentCache;
}

Matrix3x3 Transform::_getScaleMatrix() {
    Matrix3x3 worldRotScaMat;
    worldRotScaMat.setValueByMatrix(worldMatrix());
    Quaternion invRotation = invert(worldRotationQuaternion());
    Matrix3x3 invRotationMat = Matrix3x3::rotationQuaternion(invRotation);
    return invRotationMat * worldRotScaMat;
}

bool Transform::_isContainDirtyFlags(int targetDirtyFlags) {
    return (_dirtyFlag & targetDirtyFlags) == targetDirtyFlags;
}

bool Transform::_isContainDirtyFlag(int type) {
    return (_dirtyFlag & type) != 0;
}

void Transform::_setDirtyFlagTrue(int type) {
    _dirtyFlag |= type;
}

void Transform::_setDirtyFlagFalse(int type) {
    _dirtyFlag &= ~type;
}

void Transform::_worldAssociatedChange(int type) {
    _dirtyFlag |= type;
    _updateFlagManager.distribute();
}

void Transform::_rotateByQuat(const Quaternion &rotateQuat, bool relativeToLocal) {
    if (relativeToLocal) {
        _rotationQuaternion = rotationQuaternion() * rotateQuat;
        setRotationQuaternion(_rotationQuaternion);
    } else {
        _worldRotationQuaternion = worldRotationQuaternion() * rotateQuat;
        setWorldRotationQuaternion(_worldRotationQuaternion);
    }
}

void Transform::_translate(const Float3 &translation, bool relativeToLocal) {
    if (relativeToLocal) {
        _position = _position + translation;
        setPosition(_position);
    } else {
        _worldPosition = _worldPosition + translation;
        setWorldPosition(_worldPosition);
    }
}

void Transform::_rotateXYZ(float x, float y, float z, bool relativeToLocal) {
    const auto rotQuat = Quaternion::FromEuler(y * kDegreeToRadian, x * kDegreeToRadian, z * kDegreeToRadian);
    _rotateByQuat(rotQuat, relativeToLocal);
}

}
