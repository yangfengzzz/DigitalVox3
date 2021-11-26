//
//  quaternion.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/24.
//

#include "quaternion.h"
#include "matrix3x3.h"

namespace vox {
namespace math {
Quaternion Quaternion::rotationMatrix3x3(const Matrix3x3& m){
    Quaternion out;
    
    const auto& me = m.elements;
    const auto& m11 = me[0],
    m12 = me[1],
    m13 = me[2];
    const auto& m21 = me[3],
    m22 = me[4],
    m23 = me[5];
    const auto& m31 = me[6],
    m32 = me[7],
    m33 = me[8];
    const auto scale = m11 + m22 + m33;
    float sqrt, half;
    
    if (scale > 0) {
        sqrt = std::sqrt(scale + 1.0);
        out.w = sqrt * 0.5;
        sqrt = 0.5 / sqrt;
        
        out.x = (m23 - m32) * sqrt;
        out.y = (m31 - m13) * sqrt;
        out.z = (m12 - m21) * sqrt;
    } else if (m11 >= m22 && m11 >= m33) {
        sqrt = std::sqrt(1.0 + m11 - m22 - m33);
        half = 0.5 / sqrt;
        
        out.x = 0.5 * sqrt;
        out.y = (m12 + m21) * half;
        out.z = (m13 + m31) * half;
        out.w = (m23 - m32) * half;
    } else if (m22 > m33) {
        sqrt = std::sqrt(1.0 + m22 - m11 - m33);
        half = 0.5 / sqrt;
        
        out.x = (m21 + m12) * half;
        out.y = 0.5 * sqrt;
        out.z = (m32 + m23) * half;
        out.w = (m31 - m13) * half;
    } else {
        sqrt = std::sqrt(1.0 + m33 - m11 - m22);
        half = 0.5 / sqrt;
        
        out.x = (m13 + m31) * half;
        out.y = (m23 + m32) * half;
        out.z = 0.5 * sqrt;
        out.w = (m12 - m21) * half;
    }
    
    return out;
}

}
}
