//----------------------------------------------------------------------------//
//                                                                            //
// vox-animation is hosted at http://github.com/guillaumeblanc/vox-animation  //
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

#include "maths/bounding_box.h"

#include <limits>

#include "maths/math_ex.h"
#include "maths/simd_math.h"
#include "bounding_sphere.h"

namespace vox {
namespace math {

BoundingBox::BoundingBox()
: min(std::numeric_limits<float>::max()),
max(-std::numeric_limits<float>::max()) {
}

BoundingBox::BoundingBox(const Float3 *_points, size_t _stride, size_t _count) {
    assert(_stride >= sizeof(Float3) &&
           "_stride must be greater or equal to sizeof(Float3)");
    
    Float3 local_min(std::numeric_limits<float>::max());
    Float3 local_max(-std::numeric_limits<float>::max());
    
    const Float3 *end = PointerStride(_points, _stride * _count);
    for (; _points < end; _points = PointerStride(_points, _stride)) {
        local_min = Min(local_min, *_points);
        local_max = Max(local_max, *_points);
    }
    
    min = local_min;
    max = local_max;
}

BoundingBox BoundingBox::fromSphere(const BoundingSphere &sphere) {
    const auto &center = sphere.center;
    const auto &radius = sphere.radius;
    BoundingBox out;
    auto &min = out.min;
    auto &max = out.max;
    
    min.x = center.x - radius;
    min.y = center.y - radius;
    min.z = center.z - radius;
    max.x = center.x + radius;
    max.y = center.y + radius;
    max.z = center.z + radius;
    
    return out;
}


BoundingBox TransformBox(const Float4x4 &_matrix, const BoundingBox &_box) {
    const SimdFloat4 min = simd_float4::Load3PtrU(&_box.min.x);
    const SimdFloat4 max = simd_float4::Load3PtrU(&_box.max.x);
    
    // Transforms min and max.
    const SimdFloat4 ta = TransformPoint(_matrix, min);
    const SimdFloat4 tb = TransformPoint(_matrix, max);
    
    // Finds new min and max and store them in box.
    BoundingBox tbox;
    math::Store3PtrU(Min(ta, tb), &tbox.min.x);
    math::Store3PtrU(Max(ta, tb), &tbox.max.x);
    return tbox;
}

}  // namespace math
}  // namespace vox
