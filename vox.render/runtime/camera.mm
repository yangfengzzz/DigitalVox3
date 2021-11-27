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

Float4 Camera::viewport() const {
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

void Camera::resetProjectionMatrix() {
    _isProjMatSetting = false;
    _projMatChange();
}

void Camera::resetAspectRatio() {
    _customAspectRatio = std::nullopt;
    _projMatChange();
}

Float4 Camera::worldToViewportPoint(const Float3& point) {
    auto tempMat4 = projectionMatrix() * viewMatrix();
    auto tempVec4 = Float4(point.x, point.y, point.z, 1.0);
    tempVec4 = transform(tempVec4, tempMat4);
    
    const auto w = tempVec4.w;
    const auto nx = tempVec4.x / w;
    const auto ny = tempVec4.y / w;
    const auto nz = tempVec4.z / w;
    
    // Transform of coordinate axis.
    return Float4((nx + 1.0) * 0.5, (1.0 - ny) * 0.5, nz, w);
}

Float3 Camera::viewportToWorldPoint(const Float3& point) {
    return _innerViewportToWorldPoint(point, invViewProjMat());
}

Ray Camera::viewportPointToRay(const Float2& point) {
    Ray out;
    // Use the intersection of the near clipping plane as the origin point.
    Float3 clipPoint = Float3(point.x, point.y, 0);
    out.origin = viewportToWorldPoint(clipPoint);
    // Use the intersection of the far clipping plane as the origin point.
    clipPoint.z = 1.0;
    Float3 farPoint = _innerViewportToWorldPoint(clipPoint, _invViewProjMat);
    out.direction = farPoint - out.origin;
    out.direction = Normalize(out.direction);
    
    return out;
}

Float2 Camera::screenToViewportPoint(const Float2& point) {
    const auto& canvas = engine()->canvas();
    const Float4 viewport = this->viewport();
    return Float2((point.x / canvas.width() - viewport.x) / viewport.z,
                  (point.y / canvas.height() - viewport.y) / viewport.w);
}

Float3 Camera::screenToViewportPoint(const Float3& point) {
    const auto& canvas = engine()->canvas();
    const Float4 viewport = this->viewport();
    return Float3((point.x / canvas.width() - viewport.x) / viewport.z,
                  (point.y / canvas.height() - viewport.y) / viewport.w, 0);
}

Float2 Camera::viewportToScreenPoint(const Float2& point) {
    const auto& canvas = engine()->canvas();
    const Float4 viewport = this->viewport();
    return Float2((viewport.x + point.x * viewport.z) * canvas.width(),
                  (viewport.y + point.y * viewport.w) * canvas.height());
}

Float3 Camera::viewportToScreenPoint(const Float3& point) {
    const auto& canvas = engine()->canvas();
    const Float4 viewport = this->viewport();
    return Float3((viewport.x + point.x * viewport.z) * canvas.width(),
                  (viewport.y + point.y * viewport.w) * canvas.height(), 0);
}

Float4 Camera::viewportToScreenPoint(const Float4& point) {
    const auto& canvas = engine()->canvas();
    const Float4 viewport = this->viewport();
    return Float4((viewport.x + point.x * viewport.z) * canvas.width(),
                  (viewport.y + point.y * viewport.w) * canvas.height(), 0, 0);
}

Float4 Camera::worldToScreenPoint(const Float3& point) {
    auto out = worldToViewportPoint(point);
    return viewportToScreenPoint(out);
}

Float3 Camera::screenToWorldPoint(const Float3&  point) {
    auto out = screenToViewportPoint(point);
    return viewportToWorldPoint(out);
}

Ray Camera::screenPointToRay(const Float2& point) {
    Float2 viewportPoint = screenToViewportPoint(point);
    return viewportPointToRay(viewportPoint);
}

void Camera::render(std::optional<TextureCubeFace> cubeFace, int mipLevel) {
    
}

void Camera::_onActive() {
    entity()->scene()->_attachRenderCamera(this);
}

void Camera::_onInActive() {
    entity()->scene()->_detachRenderCamera(this);
}

void Camera::_onDestroy() {
    _isInvViewProjDirty->destroy();
    _isViewMatrixDirty->destroy();
}

void Camera::_projMatChange() {
    _isFrustumProjectDirty = true;
    _isProjectionDirty = true;
    _isInvProjMatDirty = true;
    _isInvViewProjDirty->flag = true;
}

Float3 Camera::_innerViewportToWorldPoint(const Float3& point, const Matrix& invViewProjMat) {
    // Depth is a normalized value, 0 is nearPlane, 1 is farClipPlane.
    const auto depth = point.z * 2 - 1;
    // Transform to clipping space matrix
    Float4 clipPoint = Float4(point.x * 2 - 1, 1 - point.y * 2, depth, 1);
    clipPoint = transform(clipPoint, invViewProjMat);
    const auto invW = 1.0 / clipPoint.w;
    return Float3(clipPoint.x * invW,
                  clipPoint.y * invW,
                  clipPoint.z * invW);
}

Matrix Camera::invViewProjMat() {
    if (_isInvViewProjDirty->flag) {
        _isInvViewProjDirty->flag = false;
        _invViewProjMat = _transform->worldMatrix() * inverseProjectionMatrix();
    }
    return _invViewProjMat;
}

Matrix Camera::inverseProjectionMatrix() {
    if (_isInvProjMatDirty) {
        _isInvProjMatDirty = false;
        _inverseProjectionMatrix = invert(projectionMatrix());
    }
    return _inverseProjectionMatrix;
}

}