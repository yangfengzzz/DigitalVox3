//----------------------------------------------------------------------------//
//                                                                            //
// ozz-animation is hosted at http://github.com/guillaumeblanc/ozz-animation  //
// and distributed under the MIT License (MIT).                               //
//                                                                            //
// Copyright (c) Guillaume Blanc                                              //
//                                                                            //
// Permission is hereby granted, free of charge, to any person obtaining a    //
// copy of this software and associated documentation files (the "Software"), //
// to deal in the Software without restriction, including without limitation  //
// the rights to use, copy, modify, merge, publish, distribute, sublicense,   //
// and/or sell copies of the Software, and to permit persons to whom the      //
// Software is furnished to do so, subject to the following conditions:       //
//                                                                            //
// The above copyright notice and this permission notice shall be included in //
// all copies or substantial portions of the Software.                        //
//                                                                            //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    //
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    //
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER        //
// DEALINGS IN THE SOFTWARE.                                                  //
//                                                                            //
//----------------------------------------------------------------------------//

#ifndef OZZ_OZZ_BASE_MATHS_BOX_H_
#define OZZ_OZZ_BASE_MATHS_BOX_H_

#include <cstddef>

#include "maths/vec_float.h"
#include "matrix.h"

namespace ozz {
namespace math {
// Matrix forward declaration.
struct Float4x4;
struct BoundingSphere;

// Defines an axis aligned box.
struct BoundingBox {
    // Constructs an invalid box.
    BoundingBox();
    
    // Constructs a box with the specified _min and _max bounds.
    BoundingBox(const Float3 &_min, const Float3 &_max) : min(_min), max(_max) {
    }
    
    // Constructs the smallest box that contains the _count points _points.
    // _stride is the number of bytes between points.
    explicit BoundingBox(const Float3 &_point) : min(_point), max(_point) {
    }
    
    // Constructs the smallest box that contains the _count points _points.
    // _stride is the number of bytes between points, it must be greater or
    // equal to sizeof(Float3).
    BoundingBox(const Float3 *_points, size_t _stride, size_t _count);
    
    /**
     * Calculate a bounding box from the center point and the extent of the bounding box.
     * @param center - The center point
     * @param extent - The extent of the bounding box
     */
    static BoundingBox fromCenterAndExtent(const Float3 &center, const Float3 &extent) {
        BoundingBox out;
        out.min = center - extent;
        out.max = center + extent;
        return out;
    }
    
    /**
     * Calculate a bounding box from a given sphere.
     * @param sphere - The given sphere
     */
    static BoundingBox fromSphere(const BoundingSphere &sphere);
    
    // Tests whether *this is a valid box.
    bool is_valid() const {
        return min <= max;
    }
    
    // Tests whether _p is within box bounds.
    bool is_inside(const Float3 &_p) const {
        return _p >= min && _p <= max;
    }
    
    /**
     * Get the center point of this bounding box.
     * @returns The center point of this bounding box
     */
    Float3 getCenter() const {
        auto out = min + max;
        out = out * 0.5;
        return out;
    }
    
    /**
     * Get the extent of this bounding box.
     * @returns The extent of this bounding box
     */
    Float3 getExtent() const {
        auto out = max - min;
        out = out * 0.5;
        return out;
    }
    
    /**
     * Get the eight corners of this bounding box.
     * @returns An array of points representing the eight corners of this bounding box
     */
    std::array<Float3, 8> getCorners() const {
        const auto& minX = min.x;
        const auto& minY = min.y;
        const auto& minZ = min.z;
        const auto& maxX = max.x;
        const auto& maxY = max.y;
        const auto& maxZ = max.z;
        
        return {
            Float3(minX, maxY, maxZ),
            Float3(maxX, maxY, maxZ),
            Float3(maxX, minY, maxZ),
            Float3(minX, minY, maxZ),
            Float3(minX, maxY, minZ),
            Float3(maxX, maxY, minZ),
            Float3(maxX, minY, minZ),
            Float3(minX, minY, minZ)
        };
    }
    
    // Box's min and max bounds.
    Float3 min;
    Float3 max;
};

// Merges two boxes _a and _b.
// Both _a and _b can be invalid.
OZZ_INLINE BoundingBox Merge(const BoundingBox &_a, const BoundingBox &_b) {
    if (!_a.is_valid()) {
        return _b;
    } else if (!_b.is_valid()) {
        return _a;
    }
    return BoundingBox(Min(_a.min, _b.min), Max(_a.max, _b.max));
}

/**
 * Transform a bounding box.
 * @param source - The original bounding box
 * @param matrix - The transform to apply to the bounding box
 * @return out - The transformed bounding box
 */
OZZ_INLINE BoundingBox transform(const BoundingBox &source, const Matrix &matrix) {
    // https://zeux.io/2010/10/17/aabb-from-obb-with-component-wise-abs/
    Float3 center = source.getCenter();
    Float3 extent = source.getExtent();
    
    transformCoordinate(center, matrix, center);
    
    const auto &x = extent.x;
    const auto &y = extent.y;
    const auto &z = extent.z;
    const auto &e = matrix.elements;
    extent.x = std::abs(x * e[0]) + std::abs(y * e[4]) + std::abs(z * e[8]);
    extent.y = std::abs(x * e[1]) + std::abs(y * e[5]) + std::abs(z * e[9]);
    extent.z = std::abs(x * e[2]) + std::abs(y * e[6]) + std::abs(z * e[10]);
    
    // set min、max
    return BoundingBox(center - extent, center + extent);
}

// Compute box transformation by a matrix.
BoundingBox TransformBox(const Float4x4 &_matrix, const BoundingBox &_box);
}  // namespace math
}  // namespace ozz
#endif  // OZZ_OZZ_BASE_MATHS_BOX_H_
