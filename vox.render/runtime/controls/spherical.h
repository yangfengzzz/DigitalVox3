//
//  spherical.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/30.
//

#ifndef spherical_hpp
#define spherical_hpp

#include "maths/vec_float.h"

namespace vox {
namespace control {
// Spherical.
class Spherical {
public:
    Spherical(float radius = 1.0, float phi = 0, float theta = 0);
    
    void set(float radius, float phi, float theta);

    void makeSafe();
    
    void setFromVec3(const math::Float3& v3);
    
    void setToVec3(math::Float3& v3);

private:
    float radius;
    float phi;
    float theta;
};

}
}

#endif /* spherical_hpp */
