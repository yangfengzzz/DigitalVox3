//
//  dynamic_collider.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/3.
//

#ifndef dynamic_collider_hpp
#define dynamic_collider_hpp

#include "collider.h"

namespace vox {
namespace physics {
class DynamicCollider: public Collider {
public:
    DynamicCollider(Entity* entity);
    
    /**
     * The linear damping of the dynamic collider.
     */
    float linearDamping();

    void setLinearDamping(float newValue);
    
};

}
}

#endif /* dynamic_collider_hpp */
