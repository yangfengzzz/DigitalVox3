//
//  box_collider_shape.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#ifndef box_collider_shape_hpp
#define box_collider_shape_hpp

#include "collider_shape.h"

namespace vox {
namespace physics {
class BoxColliderShape : public ColliderShape {
public:
    BoxColliderShape();
    
    math::Float3 size();
    
    void setSize(const math::Float3 &value);
    
    void setWorldScale(const math::Float3 &scale) override;
    
private:
    math::Float3 _half = math::Float3(0.5, 0.5, 0.5);
};

}
}
#endif /* box_collider_shape_hpp */
