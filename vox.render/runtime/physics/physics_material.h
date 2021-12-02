//
//  physics_material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#ifndef physics_material_hpp
#define physics_material_hpp

#include "physics.h"

namespace vox {
namespace physics {
class PhysicsMaterial {
public:
    PhysicsMaterial(PxMaterial* material);
    
    void setDynamicFriction(float coef);
    
    float dynamicFriction() const;
    
    void setStaticFriction(float coef);
    
    float staticFriction() const;
    
    void setRestitution(float rest);
    
    float restitution() const;
    
    void setFlag(PxMaterialFlag::Enum flag, bool b);
    
    void setFlags(PxMaterialFlags flags);
    
    PxMaterialFlags flags() const;
    
    void setFrictionCombineMode(PxCombineMode::Enum combMode);
    
    PxCombineMode::Enum frictionCombineMode() const;
    
    void setRestitutionCombineMode(PxCombineMode::Enum combMode);
    
    PxCombineMode::Enum restitutionCombineMode() const;
    
private:
    PxMaterial* material;
};

}
}

#endif /* physics_material_hpp */
