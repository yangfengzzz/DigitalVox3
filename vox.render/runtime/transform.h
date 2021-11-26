//
//  transform.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef transform_hpp
#define transform_hpp

#include "component.h"
#include "updateFlag_manager.h"
#include "maths/vec_float.h"
#include "maths/quaternion.h"
#include "maths/matrix.h"

namespace ozz {
using namespace math;
/**
 * Dirty flag of transform.
 */
enum TransformFlag {
    LocalEuler = 0x1,
    LocalQuat = 0x2,
    WorldPosition = 0x4,
    WorldEuler = 0x8,
    WorldQuat = 0x10,
    WorldScale = 0x20,
    LocalMatrix = 0x40,
    WorldMatrix = 0x80,
    
    /** WorldMatrix | WorldPosition */
    WmWp = 0x84,
    /** WorldMatrix | WorldEuler | WorldQuat */
    WmWeWq = 0x98,
    /** WorldMatrix | WorldPosition | WorldEuler | WorldQuat */
    WmWpWeWq = 0x9c,
    /** WorldMatrix | WorldScale */
    WmWs = 0xa0,
    /** WorldMatrix | WorldPosition | WorldScale */
    WmWpWs = 0xa4,
    /** WorldMatrix | WorldPosition | WorldEuler | WorldQuat | WorldScale */
    WmWpWeWqWs = 0xbc
};

/**
 * Used to implement transformation related functions.
 */
class Transform : public Component {
public:
    /**
     * Local position.
     * @remarks Need to re-assign after modification to ensure that the modification takes effect.
     */
    Float3 getPosition() {
        return _position;
    }
    
    void setPosition(const Float3& value) {
        _position = value;
        // _setDirtyFlagTrue(TransformFlag::LocalMatrix);
        // _updateWorldPositionFlag();
    }
    
private:
    Float3 _position;
    Float3 _rotation;
    Quaternion _rotationQuaternion;
    Float3 _scale = Float3(1, 1, 1);
    Float3 _worldPosition;
    Float3 _worldRotation;
    Quaternion _worldRotationQuaternion;
    Float3 _lossyWorldScale = Float3(1, 1, 1);
    Matrix _localMatrix;
    Matrix _worldMatrix;
    UpdateFlagManager _updateFlagManager;
    bool _isParentDirty = true;
    Transform* _parentTransformCache = nullptr;
    TransformFlag _dirtyFlag = TransformFlag::WmWpWeWqWs;
};


}

#endif /* transform_hpp */
