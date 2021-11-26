//
//  transform.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "transform.h"

namespace vox {
Transform::Transform(Entity* entity):Component(entity) {    
}

Float3 Transform::position() {
    return _position;
}

void Transform::setPosition(const Float3& value){
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

void Transform::setWorldPosition(const Float3& value){
    _worldPosition = value;
    const auto parent = _getParentTransform();
    if (parent) {
        const auto _tempMat41 =  invert(parent->worldMatrix());
        _position = transformCoordinate(value, _tempMat41);
    } else {
        _position = value;
    }
    setPosition(_position);
    _setDirtyFlagFalse(TransformFlag::WorldPosition);
}

}
