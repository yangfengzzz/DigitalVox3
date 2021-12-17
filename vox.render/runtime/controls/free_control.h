//
//  free_control.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/17.
//

#ifndef free_control_hpp
#define free_control_hpp

#include "../script.h"
#include "spherical.h"
#include "maths/vec_float.h"
#include <vector>

namespace vox {
namespace control {
/**
 * The camera's roaming controller, can move up and down, left and right, and rotate the viewing angle.
 */
class FreeControl :public Script {
public:
    FreeControl(Entity* entity);
    
    /**
     * Keyboard press event.
     */
    void onKeyDown();
    
    /**
     * Keyboard up event.
     */
    void onKeyUp();
    
    /**
     * Mouse press event.
     */
    void onMouseDown();
    
    /**
     * Mouse up event.
     */
    void onMouseUp();
    
    /**
     * Mouse movement event.
     */
    void onMouseMove();
    
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
    float movementSpeed;
    
    /**
     * Rotate speed.
     */
    float rotateSpeed;
    
    /**
     * Simulate a ground.
     */
    bool floorMock;
    
    /**
     * Simulated ground height.
     */
    float floorY;
    
    /**
     * Only rotate when press=true
     */
    bool press;
    
    /**
     * Radian of spherical.theta.
     */
    float _theta;
    
    /**
     * Radian of spherical.phi.
     */
    float _phi;
    
    bool _moveForward;
    bool _moveBackward;
    bool _moveLeft;
    bool _moveRight;
    
    math::Float3 _v3Cache;
    Spherical _spherical;
    std::vector<float> _rotateOri{};
};

}
}

#endif /* free_control_hpp */
