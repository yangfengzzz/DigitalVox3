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
OrbitControl::OrbitControl(Entity* entity):
Script(entity),
camera(entity) {
    windows = engine()->canvas().handle();
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
    
}

void OrbitControl::zoomIn(float zoomScale) {
    _scale *= zoomScale;
}

void OrbitControl::zoomOut(float zoomScale) {
    _scale /= zoomScale;
}


}
}
