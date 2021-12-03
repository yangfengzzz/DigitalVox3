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
    ColliderShape();
    
    Collider* collider();
        
public:
    void setLocalPose(const math::Transform &pose);
    
    math::Transform localPose() const;
    
    void setPosition(const math::Float3& pos);
    
    math::Float3 position() const;
    
    virtual void setWorldScale(const math::Float3& scale) = 0;
    
public:
    void setMaterial(PxMaterial* materials);
    
    PxMaterial* material();
    
public:
    void setQueryFilterData(const PxFilterData &data);
    
    PxFilterData queryFilterData();

    uint32_t uniqueID();
        
public:
    bool trigger();
    
    void setTrigger(bool isTrigger);
    
    bool sceneQuery();
    
    void setSceneQuery(bool isQuery);
    
protected:
    friend class Collider;
    
    PxShape* _nativeShape;
    std::shared_ptr<PxGeometry> _nativeGeometry;
    PxMaterial* _nativeMaterial;

    Collider* _collider;

    math::Transform _pose;
    static const float halfSqrt;
};

}
}
#endif /* collider_shape_hpp */
