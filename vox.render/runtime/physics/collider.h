//
//  collider.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#ifndef collider_hpp
#define collider_hpp

#include "physics.h"
#include "../component.h"
#include "../updateFlag.h"
#include <vector>

namespace vox {
namespace physics {

class Collider: public Component {
public:
    Collider(Entity* entity);
    
    void addShape(const ColliderShape& shape);
    
    void removeShape(const ColliderShape& shape);
    
    void clearShapes();
    
public:
    void _onUpdate();
    
    virtual void _onLateUpdate(){}
    
    void _onEnable() override;
    
    void _onDisable() override;
    
    void _onDestroy() override;
    
private:
    ssize_t _index = -1;
    std::unique_ptr<UpdateFlag> _updateFlag;
    physx::PxRigidActor * _pxActor;
    std::vector<ColliderShapePtr> _shapes;
};

}
}
#endif /* collider_hpp */
