//
//  orbit_control.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/30.
//

#include "orbit_control.h"
#include "../engine.h"

namespace vox {
namespace control {
void onMouseDownCallback(GLFWwindow* window, int button, int action, int mods) {
    static_cast<OrbitControl*>(glfwGetWindowUserPointer(window))->onMouseDown(window, button, action, mods);
}

void onMouseWheelCallback(GLFWwindow* window, double xoffset, double yoffset) {
    static_cast<OrbitControl*>(glfwGetWindowUserPointer(window))->onMouseWheel(window, xoffset, yoffset);
}

OrbitControl::OrbitControl(Entity* entity):
Script(entity),
camera(entity) {
    windows = engine()->canvas().handle();
    
    glfwSetWindowUserPointer(windows, this);
    glfwSetMouseButtonCallback(windows, onMouseDownCallback);
    glfwSetScrollCallback(windows, onMouseWheelCallback);
}

void OrbitControl::onDisable() {
    
}

void OrbitControl::onDestroy() {
    
}

void OrbitControl::onUpdate(float dtime) {
    if (!enabled()) return;
    
    const auto& position = camera->transform->position();
    _offset = position;
    _offset = _offset - target;
    _spherical.setFromVec3(_offset);
    
    if (autoRotate && _state == STATE::NONE) {
        rotateLeft(autoRotationAngle(dtime));
    }
    
    _spherical.theta += _sphericalDelta.theta;
    _spherical.phi += _sphericalDelta.phi;
    
    _spherical.theta = std::max(minAzimuthAngle, std::min(maxAzimuthAngle, _spherical.theta));
    _spherical.phi = std::max(minPolarAngle, std::min(maxPolarAngle, _spherical.phi));
    _spherical.makeSafe();
    
    if (_scale != 1) {
        _zoomFrag = _spherical.radius * (_scale - 1);
    }
    
    _spherical.radius += _zoomFrag;
    _spherical.radius = std::max(minDistance, std::min(maxDistance, _spherical.radius));
    
    target = target + _panOffset;
    _spherical.setToVec3(_offset);
    _position = target;
    _position = _position + _offset;
    
    camera->transform->setPosition(_position);
    camera->transform->lookAt(target, up);
    
    if (enableDamping == true) {
        _sphericalDump.theta *= 1 - dampingFactor;
        _sphericalDump.phi *= 1 - dampingFactor;
        _zoomFrag *= 1 - zoomFactor;
        
        if (_isMouseUp) {
            _sphericalDelta.theta = _sphericalDump.theta;
            _sphericalDelta.phi = _sphericalDump.phi;
        } else {
            _sphericalDelta.set(0, 0, 0);
        }
    } else {
        _sphericalDelta.set(0, 0, 0);
        _zoomFrag = 0;
    }
    
    _scale = 1;
    _panOffset = math::Float3(0, 0, 0);
}

float OrbitControl::autoRotationAngle(float dtime) {
    return (autoRotateSpeed / 1000) * dtime;
}

float OrbitControl::zoomScale() {
    return std::pow(0.95, zoomSpeed);
}

void OrbitControl::rotateLeft(float radian) {
    _sphericalDelta.theta -= radian;
    if (enableDamping) {
        _sphericalDump.theta = -radian;
    }
}

void OrbitControl::rotateUp(float radian) {
    _sphericalDelta.phi -= radian;
    if (enableDamping) {
        _sphericalDump.phi = -radian;
    }
}

void OrbitControl::panLeft(float distance, const math::Matrix& worldMatrix) {
    const auto& e = worldMatrix.elements;
    _vPan = Float3(e[0], e[1], e[2]);
    _vPan = _vPan * distance;
    _panOffset = _panOffset + _vPan;
}

void OrbitControl::panUp(float distance, const math::Matrix& worldMatrix) {
    const auto& e = worldMatrix.elements;
    _vPan = Float3(e[4], e[5], e[6]);
    _vPan = _vPan * distance;
    _panOffset = _panOffset + _vPan;
}

void OrbitControl::pan(float deltaX, float deltaY) {
    // perspective only
    Float3 position = camera->transform->position();
    _vPan = position;
    _vPan = _vPan - target;
    auto targetDistance = Length(_vPan);

    targetDistance *= (fov / 2) * (M_PI / 180);

    int width, height;
    glfwGetWindowSize(windows, &width, &height);
    panLeft(-2 * deltaX * (targetDistance / float(width)), camera->transform->worldMatrix());
    panUp(2 * deltaY * (targetDistance / float(height)), camera->transform->worldMatrix());
}

void OrbitControl::zoomIn(float zoomScale) {
    _scale *= zoomScale;
}

void OrbitControl::zoomOut(float zoomScale) {
    _scale /= zoomScale;
}

//MARK: - Mouse
void OrbitControl::handleMouseDownRotate() {
    double x, y;
    glfwGetCursorPos(windows, &x, &y);
    _rotateStart = Float2(x, y);
}

void OrbitControl::handleMouseDownZoom() {
    double x, y;
    glfwGetCursorPos(windows, &x, &y);
    _zoomStart = Float2(x, y);
}

void OrbitControl::handleMouseDownPan(){
    double x, y;
    glfwGetCursorPos(windows, &x, &y);
    _panStart = Float2(x, y);
}

void OrbitControl::handleMouseMoveRotate(){
    double x, y;
    glfwGetCursorPos(windows, &x, &y);
    
    _rotateEnd = Float2(x, y);
    _rotateDelta = _rotateEnd - _rotateStart;
    
    int width, height;
    glfwGetWindowSize(windows, &width, &height);
    rotateLeft(2 * M_PI * (_rotateDelta.x / float(width)) * rotateSpeed);
    rotateUp(2 * M_PI * (_rotateDelta.y / float(height)) * rotateSpeed);
    
    _rotateStart = _rotateEnd;
}

void OrbitControl::handleMouseMoveZoom(){
    double x, y;
    glfwGetCursorPos(windows, &x, &y);
    
    _zoomEnd = Float2(x, y);
    _zoomDelta = _zoomEnd - _zoomStart;
    
    if (_zoomDelta.y > 0) {
        zoomOut(zoomScale());
    } else if (_zoomDelta.y < 0) {
        zoomIn(zoomScale());
    }
    
    _zoomStart = _zoomEnd;
}

void OrbitControl::handleMouseMovePan(){
    double x, y;
    glfwGetCursorPos(windows, &x, &y);
    
    _panEnd = Float2(x, y);
    _panDelta = _panEnd - _panStart;
    
    pan(_panDelta.x, _panDelta.y);
    
    _panStart = _panEnd;
}

void OrbitControl::handleMouseWheel(double xoffset, double yoffset){
    if (yoffset < 0) {
        zoomIn(zoomScale());
    } else if (yoffset > 0) {
        zoomOut(zoomScale());
    }
}

void OrbitControl::onMouseDown(GLFWwindow* window, int button, int action, int mods){
    if (enabled() == false) return;
    
    _isMouseUp = false;
    
    switch (button) {
        case GLFW_MOUSE_BUTTON_LEFT:
            if (enableRotate == false) return;
            
            handleMouseDownRotate();
            _state = STATE::ROTATE;
            break;
        case GLFW_MOUSE_BUTTON_MIDDLE:
            if (enableZoom == false) return;
            
            handleMouseDownZoom();
            _state = STATE::ZOOM;
            break;
        case GLFW_MOUSE_BUTTON_RIGHT:
            if (enablePan == false) return;
            
            handleMouseDownPan();
            _state = STATE::PAN;
            break;
        default:
            break;
    }
    
    if (_state != STATE::NONE) {
        onMouseMove();
        onMouseUp();
    }
}

void OrbitControl::onMouseMove(){
    if (enabled() == false) return;
    
    switch (_state) {
        case STATE::ROTATE:
            if (enableRotate == false) return;
            
            handleMouseMoveRotate();
            break;
            
        case STATE::ZOOM:
            if (enableZoom == false) return;
            
            handleMouseMoveZoom();
            break;
            
        case STATE::PAN:
            if (enablePan == false) return;
            
            handleMouseMovePan();
            break;
        default:
            break;;
    }
}

void OrbitControl::onMouseUp(){
    if (enabled() == false) return;
    
    _isMouseUp = true;
    _state = STATE::NONE;
}

void OrbitControl::onMouseWheel(GLFWwindow* window, double xoffset, double yoffset){
    if (enabled() == false || enableZoom == false ||
        (_state != STATE::NONE && _state != STATE::ROTATE))
        return;
    
    handleMouseWheel(xoffset, yoffset);
}

//MARK: - KeyBoard
void OrbitControl::handleKeyDown(){}

void OrbitControl::onKeyDown(){}

//MARK: - Touch
void OrbitControl::handleTouchStartRotate(){}

void OrbitControl::handleTouchStartZoom(){}

void OrbitControl::handleTouchStartPan(){}

void OrbitControl::handleTouchMoveRotate(){}

void OrbitControl::handleTouchMoveZoom(){}

void OrbitControl::handleTouchMovePan(){}

void OrbitControl::onTouchStart(){}

void OrbitControl::onTouchMove(){}

void OrbitControl::onTouchEnd(){}

}
}
