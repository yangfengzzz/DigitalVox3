//
//  free_control.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/17.
//

#include "free_control.h"
#include "../entity.h"
#include "maths/math_ex.h"

namespace vox {
namespace control {
FreeControl::FreeControl(Entity *entity) :
Script(entity) {
    cursorPosCallback = [&](GLFWwindow *window, double xpos, double ypos) {
        onMouseMove(window, xpos, ypos);
    };
    
    keyCallback = [&](GLFWwindow *window, int key, int scancode, int action, int mods) {
        if (action == GLFW_PRESS) {
            onKeyDown(key);
        } else if (action == GLFW_RELEASE) {
            onKeyUp(key);
        }
    };
    
    mouseButtonCallback = [&](GLFWwindow *window, int button, int action, int mods) {
        if (action == GLFW_PRESS) {
            onMouseDown(window);
        } else if (action == GLFW_RELEASE) {
            onMouseUp();
        }
    };
    
    initEvents();
    
    // init spherical
    updateSpherical();
}

void FreeControl::onKeyDown(int key) {
    switch (key) {
        case GLFW_KEY_W:
        case GLFW_KEY_UP:
            _moveForward = true;
            break;
            
        case GLFW_KEY_S:
        case GLFW_KEY_DOWN:
            _moveBackward = true;
            break;
            
        case GLFW_KEY_A:
        case GLFW_KEY_LEFT:
            _moveLeft = true;
            break;
            
        case GLFW_KEY_D:
        case GLFW_KEY_RIGHT:
            _moveRight = true;
            break;
            
        default:
            break;
    }
}

void FreeControl::onKeyUp(int key) {
    switch (key) {
        case GLFW_KEY_W:
        case GLFW_KEY_UP:
            _moveForward = false;
            break;
            
        case GLFW_KEY_S:
        case GLFW_KEY_DOWN:
            _moveBackward = false;
            break;
            
        case GLFW_KEY_A:
        case GLFW_KEY_LEFT:
            _moveLeft = false;
            break;
            
        case GLFW_KEY_D:
        case GLFW_KEY_RIGHT:
            _moveRight = false;
            break;
            
        default:
            break;
    }
}

void FreeControl::onMouseDown(GLFWwindow *window) {
    press = true;
    glfwGetCursorPos(window, &_rotateOri[0], &_rotateOri[1]);
}

void FreeControl::onMouseUp() {
    press = false;
}

void FreeControl::onMouseMove(GLFWwindow *window, double clientX, double clientY) {
    if (press == false) return;
    if (enabled() == false) return;
    
    int width, height;
    glfwGetWindowSize(window, &width, &height);
    
    const auto movementX = clientX - _rotateOri[0];
    const auto movementY = clientY - _rotateOri[1];
    _rotateOri[0] = clientX;
    _rotateOri[1] = clientY;
    const auto factorX = 180.0 / width;
    const auto factorY = 180.0 / height;
    const auto actualX = movementX * factorX;
    const auto actualY = movementY * factorY;
    
    rotate(-actualX, actualY);
}

void FreeControl::rotate(float alpha, float beta) {
    _theta += math::degreeToRadian(alpha);
    _phi += math::degreeToRadian(beta);
    _phi = math::Clamp<float>(_phi, 1e-6, M_PI - 1e-6);
    _spherical.theta = _theta;
    _spherical.phi = _phi;
    _spherical.setToVec3(_v3Cache);
    _v3Cache = _v3Cache + entity()->transform->position();
    entity()->transform->lookAt(_v3Cache, Float3(0, 1, 0));
}

void FreeControl::onUpdate(float delta) {
    if (enabled() == false) return;
    
    const auto actualMoveSpeed = delta * movementSpeed;
    _forward = entity()->transform->worldForward();
    _right = entity()->transform->worldRight();
    
    if (_moveForward) {
        entity()->transform->translate(_forward * actualMoveSpeed, false);
    }
    if (_moveBackward) {
        entity()->transform->translate(_forward * (-actualMoveSpeed), false);
    }
    if (_moveLeft) {
        entity()->transform->translate(_right * (-actualMoveSpeed), false);
    }
    if (_moveRight) {
        entity()->transform->translate(_right * actualMoveSpeed, false);
    }
    
    if (floorMock) {
        const auto position = entity()->transform->position();
        if (position.y != floorY) {
            entity()->transform->setPosition(position.x, floorY, position.z);
        }
    }
}

void FreeControl::initEvents() {
    Canvas::mouse_button_callbacks.push_back(mouseButtonCallback);
    mouseCallbackIndex = Canvas::mouse_button_callbacks.size() - 1;
    Canvas::key_callbacks.push_back(keyCallback);
    keyCallbackIndex = Canvas::key_callbacks.size() - 1;
    Canvas::cursor_callbacks.push_back(cursorPosCallback);
    cursorCallbackIndex = Canvas::cursor_callbacks.size() - 1;
}

void FreeControl::onDestroy() {
    Canvas::mouse_button_callbacks.erase(Canvas::mouse_button_callbacks.begin() + mouseCallbackIndex);
    mouseCallbackIndex = -1;
    Canvas::key_callbacks.erase(Canvas::key_callbacks.begin() + keyCallbackIndex);
    keyCallbackIndex = -1;
    Canvas::cursor_callbacks.erase(Canvas::cursor_callbacks.begin() + cursorCallbackIndex);
    cursorCallbackIndex = -1;
}

void FreeControl::updateSpherical() {
    _v3Cache = math::Float3(0, 0, -1);
    _v3Cache = transformByQuat(_v3Cache, entity()->transform->rotationQuaternion());
    _spherical.setFromVec3(_v3Cache);
    _theta = _spherical.theta;
    _phi = _spherical.phi;
}

}
}
