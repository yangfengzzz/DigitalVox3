//
//  bounding_sphere.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/24.
//

#ifndef bounding_sphere_hpp
#define bounding_sphere_hpp

#include <cstddef>

#include "maths/vec_float.h"

namespace ozz {
namespace math {
struct BoundingBox;

struct BoundingSphere {
    /** The center point of the sphere. */
    Float3 center;
    /** The radius of the sphere. */
    float radius = 0;
    
    BoundingSphere():center(Float3()), radius(0) {}
    
    // Constructs the smallest box that contains the _count points _points.
    // _stride is the number of bytes between points, it must be greater or
    // equal to sizeof(Float3).
    BoundingSphere(const Float3* _points, size_t _stride, size_t _count) {
        Float3 _center;
        
        // Calculate the center of the sphere.
        for (auto i = 0; i < _count; ++i) {
            _center = _points[i] + _center;
        }
        
        // The center of the sphere.
        center = _center * 1.0 / _count;
        
        // Calculate the radius of the sphere.
        float _radius = 0.0;
        for (auto i = 0; i < _count; ++i) {
            const auto distance = LengthSqr(_center - _points[i]);
            distance > _radius && (_radius = distance);
        }
        // The radius of the sphere.
        radius = std::sqrt(_radius);
    }
    
    /**
     * Calculate a bounding sphere from a given box.
     * @param box - The given box
     * @return out - The calculated bounding sphere
     */
    static BoundingSphere fromBox(const BoundingBox& box);
};


}
}
#endif /* bounding_sphere_hpp */
