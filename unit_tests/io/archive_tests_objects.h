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

#ifndef VOX_TEST_BASE_IO_ARCHIVE_TESTS_OBJECTS_H_
#define VOX_TEST_BASE_IO_ARCHIVE_TESTS_OBJECTS_H_

#include "io/archive_traits.h"
#include "platform.h"

namespace vox {
namespace io {
class OArchive;
class IArchive;
}  // namespace io
}  // namespace vox

struct Intrusive {
  explicit Intrusive(int32_t _i = 12) : i(_i) {}
  void Save(vox::io::OArchive& _archive) const;
  void Load(vox::io::IArchive& _archive, uint32_t _version);
  int32_t i;
};

struct Extrusive {
  uint64_t i;
};

namespace vox {
namespace io {
// Give Intrusive type a version.
VOX_IO_TYPE_VERSION(46, Intrusive)

// Extrusive is not versionable.
VOX_IO_TYPE_NOT_VERSIONABLE(Extrusive)

// Specializes Extrusive type external Save and Load functions.
template <>
struct Extern<Extrusive> {
  static void Save(OArchive& _archive, const Extrusive* _test, size_t _count);
  static void Load(IArchive& _archive, Extrusive* _test, size_t _count,
                   uint32_t _version);
};
}  // namespace io
}  // namespace vox

class Tagged1 {
 public:
  void Save(vox::io::OArchive& _archive) const;
  void Load(vox::io::IArchive& _archive, uint32_t _version);
};

class Tagged2 {
 public:
  void Save(vox::io::OArchive& _archive) const;
  void Load(vox::io::IArchive& _archive, uint32_t _version);
};

namespace vox {
namespace io {
VOX_IO_TYPE_NOT_VERSIONABLE(Tagged1)
VOX_IO_TYPE_TAG("tagged1", Tagged1)
VOX_IO_TYPE_NOT_VERSIONABLE(Tagged2)
VOX_IO_TYPE_TAG("tagged2", Tagged2)
}  // namespace io
}  // namespace vox
#endif  // VOX_TEST_BASE_IO_ARCHIVE_TESTS_OBJECTS_H_
