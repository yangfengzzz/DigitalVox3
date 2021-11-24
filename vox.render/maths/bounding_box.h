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

namespace ozz {
namespace math {

// Matrix forward declaration.
struct Float4x4;

// Defines an axis aligned box.
struct BoundingBox {
    // Constructs an invalid box.
    BoundingBox();
    
    // Constructs a box with the specified _min and _max bounds.
    BoundingBox(const Float3& _min, const Float3& _max) : min(_min), max(_max) {}
    
    // Constructs the smallest box that contains the _count points _points.
    // _stride is the number of bytes between points.
    explicit BoundingBox(const Float3& _point) : min(_point), max(_point) {}
    
    // Constructs the smallest box that contains the _count points _points.
    // _stride is the number of bytes between points, it must be greater or
    // equal to sizeof(Float3).
    BoundingBox(const Float3* _points, size_t _stride, size_t _count);
    
    // Tests whether *this is a valid box.
    bool is_valid() const { return min <= max; }
    
    // Tests whether _p is within box bounds.
    bool is_inside(const Float3& _p) const { return _p >= min && _p <= max; }
    
    // Box's min and max bounds.
    Float3 min;
    Float3 max;
};

// Merges two boxes _a and _b.
// Both _a and _b can be invalid.
OZZ_INLINE BoundingBox Merge(const BoundingBox& _a, const BoundingBox& _b) {
    if (!_a.is_valid()) {
        return _b;
    } else if (!_b.is_valid()) {
        return _a;
    }
    return BoundingBox(Min(_a.min, _b.min), Max(_a.max, _b.max));
}

// Compute box transformation by a matrix.
BoundingBox TransformBox(const Float4x4& _matrix, const BoundingBox& _box);
}  // namespace math
}  // namespace ozz
#endif  // OZZ_OZZ_BASE_MATHS_BOX_H_
