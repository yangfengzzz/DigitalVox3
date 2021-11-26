//
//  camera.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "camera.h"
#include "entity.h"
#include "engine.h"

namespace vox {
Camera::Camera(Entity* entity):Component(entity) {
    auto transform = entity->transform;
    _transform = transform;
    _isViewMatrixDirty = transform->registerWorldChangeFlag();
    _isInvViewProjDirty = transform->registerWorldChangeFlag();
    _frustumViewChangeFlag = transform->registerWorldChangeFlag();
}

float Camera::nearClipPlane() {
    return _nearClipPlane;
}

void Camera::setNearClipPlane(float value) {
    _nearClipPlane = value;
    _projMatChange();
}

float Camera::farClipPlane() {
    return _farClipPlane;
}

void Camera::setFarClipPlane(float value) {
    _farClipPlane = value;
    _projMatChange();
}

float Camera::fieldOfView() {
    return _fieldOfView;
}

void Camera::setFieldOfView(float value) {
    _fieldOfView = value;
    _projMatChange();
}

float Camera::aspectRatio() {
    const auto& canvas = _entity->engine()->canvas();
    if (_customAspectRatio == std::nullopt) {
        return (canvas.width() * _viewport.z) / (canvas.height() * _viewport.w);
    } else {
        return _customAspectRatio.value();
    }
}

void Camera::setAspectRatio(float value) {
    _customAspectRatio = value;
    _projMatChange();
}

Float4 Camera::viewport() {
    return _viewport;
}

void Camera::setViewport(const Float4& value) {
    _viewport = value;
    _projMatChange();
}

bool Camera::isOrthographic() {
    return _isOrthographic;
}

void Camera::setIsOrthographic(bool value) {
    _isOrthographic = value;
    _projMatChange();
}

float Camera::orthographicSize() {
    return _orthographicSize;
}

void Camera::setOrthographicSize(float value) {
    _orthographicSize = value;
    _projMatChange();
}

Matrix Camera::viewMatrix() {
    // Remove scale
    if (_isViewMatrixDirty->flag) {
        _isViewMatrixDirty->flag = false;
        _viewMatrix = invert(_transform->worldMatrix());
    }
    return _viewMatrix;
}

void Camera::setProjectionMatrix(const Matrix& value) {
    _projectionMatrix = value;
    _isProjMatSetting = true;
    _projMatChange();
}

Matrix Camera::projectionMatrix() {
    const auto& canvas = _entity->engine()->canvas();
    if ((!_isProjectionDirty || _isProjMatSetting) &&
        _lastAspectSize.x == canvas.width() &&
        _lastAspectSize.y == canvas.height()) {
        return _projectionMatrix;
    }
    _isProjectionDirty = false;
    _lastAspectSize.x = canvas.width();
    _lastAspectSize.y = canvas.height();
    if (!_isOrthographic) {
        _projectionMatrix = Matrix::perspective(degreeToRadian(_fieldOfView),
                                                aspectRatio(),
                                                _nearClipPlane,
                                                _farClipPlane);
    } else {
        const auto width = _orthographicSize * aspectRatio();
        const auto height = _orthographicSize;
        _projectionMatrix = Matrix::ortho(-width, width, -height, height, _nearClipPlane, _farClipPlane);
    }
    return _projectionMatrix;
}

bool Camera::enableHDR() {
    return false;
}

void Camera::setEnableHDR(bool value) {
    assert(false && "not implementation");
}

}
