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

#include "archive_tests_objects.h"

#include "gtest.h"

#include "io/archive.h"

void Intrusive::Save(vox::io::OArchive& _archive) const { _archive << i; }

void Intrusive::Load(vox::io::IArchive& _archive, uint32_t _version) {
  EXPECT_EQ(_version, 46u);
  _archive >> i;
}

namespace vox {
namespace io {

// Specializes Extrusive type external Save and Load functions.
void Extern<Extrusive>::Save(OArchive& _archive, const Extrusive* _test,
                             size_t _count) {
  _archive << vox::io::MakeArray(&_test->i, _count);
}
void Extern<Extrusive>::Load(IArchive& _archive, Extrusive* _test,
                             size_t _count, uint32_t _version) {
  EXPECT_EQ(_version, 0u);
  _archive >> vox::io::MakeArray(&_test->i, _count);
}
}  // namespace io
}  // namespace vox

void Tagged1::Save(vox::io::OArchive& /*_archive*/) const {}
void Tagged1::Load(vox::io::IArchive& /*_archive*/, uint32_t /*_version*/) {}
void Tagged2::Save(vox::io::OArchive& /*_archive*/) const {}
void Tagged2::Load(vox::io::IArchive& /*_archive*/, uint32_t /*_version*/) {}
