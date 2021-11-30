//
//  orbit_control.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/30.
//

#ifndef orbit_control_hpp
#define orbit_control_hpp

#include "../script.h"
#include "maths/vec_float.h"
#include "spherical.h"
#include <GLFW/glfw3.h>

namespace vox {
namespace control {
/**
 * The camera's track controller, can rotate, zoom, pan, support mouse and touch events.
 */
class OrbitControl : public Script {
public:
    explicit OrbitControl(Entity* entity);

private:
    enum STATE {
        NONE = -1,
        ROTATE = 0,
        ZOOM = 1,
        PAN = 2,
        TOUCH_ROTATE = 3,
        TOUCH_ZOOM = 4,
        TOUCH_PAN = 5
    };
    
    EntityPtr camera;
    GLFWwindow* windows;
    float fov;
    math::Float3 target;
    math::Float3 up;
    float minDistance;
    float maxDistance;
    float minZoom;
    float maxZoom;
    bool enableDamping;
    float zoomFactor;
    bool enableRotate;
    float keyPanSpeed;
    float minPolarAngle;
    float maxPolarAngle;
    float minAzimuthAngle;
    float maxAzimuthAngle;
    bool enableZoom;
    float dampingFactor;
    float zoomSpeed;
    bool enablePan;
    bool autoRotate;
    /** The radian of automatic rotation per second. */
    float autoRotateSpeed = M_PI;
    float rotateSpeed;
    bool enableKeys;
    
    math::Float3 _position;
    math::Float3 _offset;
    Spherical _spherical;
    Spherical _sphericalDelta;
    Spherical _sphericalDump;
    float _zoomFrag;
    float _scale;
    math::Float3 _panOffset;
    bool _isMouseUp;
    math::Float3 _vPan;
    STATE _state;
    math::Float2 _rotateStart;
    math::Float2 _rotateEnd;
    math::Float2 _rotateDelta;
    math::Float2 _panStart;
    math::Float2 _panEnd;
    math::Float2 _panDelta;
    math::Float2 _zoomStart;
    math::Float2 _zoomEnd;
    math::Float2 _zoomDelta;
};

}
}

#endif /* orbit_control_hpp */
