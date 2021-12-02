//
//  collider_shape.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#ifndef collider_shape_hpp
#define collider_shape_hpp

#include "../physics.h"
#include "maths/transform.h"
#include <vector>

namespace vox {
namespace physics {
class ColliderShape {
public:
    Collider* collider();
    
public:
    void setLocalPose(const math::Transform &pose);
    
    math::Transform localPose() const;
    
    void setPosition(const math::Float3& pos);
    
    math::Float3 position() const;
    
public:
    void setMaterial(const PhysicsMaterial& materials);
    
public:
    PxFilterData queryFilterData();
    
    void setQueryFilterData(const PxFilterData &data);
    
    int uniqueID();
    
    void setUniqueID(int id);
    
public:
    bool trigger();
    
    void setTrigger(bool isTrigger);
    
    bool sceneQuery();
    
    void setSceneQuery(bool isQuery);
    
protected:
    friend class Collider;
    
    math::Transform _pose;
    PxShape* _pxShape;
    PxGeometry* _pxGeometry;
    Collider* _collider;
};

}
}

#endif /* collider_shape_hpp */
