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

#ifndef VOX_VOX_BASE_MATHS_MATH_ARCHIVE_H_
#define VOX_VOX_BASE_MATHS_MATH_ARCHIVE_H_

#include "io/archive_traits.h"
#include "platform.h"

namespace vox {
namespace math {
struct Float2;
struct Float3;
struct Float4;
struct Quaternion;
struct Transform;
struct BoundingBox;
struct RectFloat;
struct RectInt;
}  // namespace math
namespace io {
VOX_IO_TYPE_NOT_VERSIONABLE(math::Float2)
template <>
struct Extern<math::Float2> {
  static void Save(OArchive& _archive, const math::Float2* _values,
                   size_t _count);
  static void Load(IArchive& _archive, math::Float2* _values, size_t _count,
                   uint32_t _version);
};

VOX_IO_TYPE_NOT_VERSIONABLE(math::Float3)
template <>
struct Extern<math::Float3> {
  static void Save(OArchive& _archive, const math::Float3* _values,
                   size_t _count);
  static void Load(IArchive& _archive, math::Float3* _values, size_t _count,
                   uint32_t _version);
};

VOX_IO_TYPE_NOT_VERSIONABLE(math::Float4)
template <>
struct Extern<math::Float4> {
  static void Save(OArchive& _archive, const math::Float4* _values,
                   size_t _count);
  static void Load(IArchive& _archive, math::Float4* _values, size_t _count,
                   uint32_t _version);
};

VOX_IO_TYPE_NOT_VERSIONABLE(math::Quaternion)
template <>
struct Extern<math::Quaternion> {
  static void Save(OArchive& _archive, const math::Quaternion* _values,
                   size_t _count);
  static void Load(IArchive& _archive, math::Quaternion* _values, size_t _count,
                   uint32_t _version);
};

VOX_IO_TYPE_NOT_VERSIONABLE(math::Transform)
template <>
struct Extern<math::Transform> {
  static void Save(OArchive& _archive, const math::Transform* _values,
                   size_t _count);
  static void Load(IArchive& _archive, math::Transform* _values, size_t _count,
                   uint32_t _version);
};

VOX_IO_TYPE_NOT_VERSIONABLE(math::BoundingBox)
template <>
struct Extern<math::BoundingBox> {
  static void Save(OArchive& _archive, const math::BoundingBox* _values, size_t _count);
  static void Load(IArchive& _archive, math::BoundingBox* _values, size_t _count,
                   uint32_t _version);
};

VOX_IO_TYPE_NOT_VERSIONABLE(math::RectFloat)
template <>
struct Extern<math::RectFloat> {
  static void Save(OArchive& _archive, const math::RectFloat* _values,
                   size_t _count);
  static void Load(IArchive& _archive, math::RectFloat* _values, size_t _count,
                   uint32_t _version);
};

VOX_IO_TYPE_NOT_VERSIONABLE(math::RectInt)
template <>
struct Extern<math::RectInt> {
  static void Save(OArchive& _archive, const math::RectInt* _values,
                   size_t _count);
  static void Load(IArchive& _archive, math::RectInt* _values, size_t _count,
                   uint32_t _version);
};
}  // namespace io
}  // namespace vox
#endif  // VOX_VOX_BASE_MATHS_MATH_ARCHIVE_H_
