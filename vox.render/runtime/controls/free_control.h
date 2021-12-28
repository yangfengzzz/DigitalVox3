//
//  free_control.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/17.
//

#ifndef free_control_hpp
#define free_control_hpp

#include "../canvas.h"
#include "../script.h"
#include "spherical.h"
#include "maths/vec_float.h"
#include <array>

namespace vox {
namespace control {
/**
 * The camera's roaming controller, can move up and down, left and right, and rotate the viewing angle.
 */
class FreeControl : public Script {
public:
    FreeControl(Entity *entity);
    
    /**
     * Keyboard press event.
     */
    void onKeyDown(int key);
    
    /**
     * Keyboard up event.
     */
    void onKeyUp(int key);
    
    /**
     * Mouse press event.
     */
    void onMouseDown(GLFWwindow *window);
    
    /**
     * Mouse up event.
     */
    void onMouseUp();
    
    /**
     * Mouse movement event.
     */
    void onMouseMove(GLFWwindow *window, double xpos, double ypos);
    
    /**
     * The angle of rotation around the y axis and the x axis respectively.
     * @param alpha - Radian to rotate around the y axis
     * @param beta - Radian to rotate around the x axis
     */
    void rotate(float alpha = 0, float beta = 0);
    
    void onUpdate(float delta) override;
    
    /**
     * Register browser events.
     */
    void initEvents();
    
    void onDestroy() override;
    
    /**
     * must updateSpherical after quaternion has been changed
     * @example
     * Entity#lookAt([0,1,0],[0,1,0]);
     * AFreeControls#updateSpherical();
     */
    void updateSpherical();
    
private:
    math::Float3 _forward;
    math::Float3 _right;
    
    /**
     * Movement distance per second, the unit is the unit before MVP conversion.
     */
    float movementSpeed = 1.0;
    
    /**
     * Rotate speed.
     */
    float rotateSpeed = 1.0;
    
    /**
     * Simulate a ground.
     */
    bool floorMock = false;
    
    /**
     * Simulated ground height.
     */
    float floorY = 0;
    
    /**
     * Only rotate when press=true
     */
    bool press = false;
    
    /**
     * Radian of spherical.theta.
     */
    float _theta = 0;
    
    /**
     * Radian of spherical.phi.
     */
    float _phi = 0;
    
    bool _moveForward = false;
    bool _moveBackward = false;
    bool _moveLeft = false;
    bool _moveRight = false;
    
    math::Float3 _v3Cache;
    Spherical _spherical;
    std::array<double, 2> _rotateOri{};
    
    ssize_t cursorCallbackIndex = -1;
    Canvas::CursorPosFunc cursorPosCallback;
    ssize_t keyCallbackIndex = -1;
    Canvas::KeyFunc keyCallback;
    ssize_t mouseCallbackIndex = -1;
    Canvas::MouseButtonFunc mouseButtonCallback;
};

}
}

#endif /* free_control_hpp */
