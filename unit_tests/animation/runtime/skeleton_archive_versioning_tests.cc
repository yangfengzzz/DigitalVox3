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

#include "runtime/animation/skeleton.h"

#include "gtest.h"

#include "io/archive.h"
#include "io/stream.h"

#include "log.h"
#include "options/options.h"

VOX_OPTIONS_DECLARE_STRING(file, "Specifies input file", "", true)
VOX_OPTIONS_DECLARE_INT(joints, "Number of joints", 0, true)
VOX_OPTIONS_DECLARE_STRING(root_name, "Name of the root joint", "", true)

int main(int _argc, char** _argv) {
  // Parses arguments.
  testing::InitGoogleTest(&_argc, _argv);
  vox::options::ParseResult parse_result = vox::options::ParseCommandLine(
      _argc, _argv, "1.0",
      "Test Skeleton archive versioning retrocompatibility");
  if (parse_result != vox::options::kSuccess) {
    return parse_result == vox::options::kExitSuccess ? EXIT_SUCCESS
                                                      : EXIT_FAILURE;
  }

  return RUN_ALL_TESTS();
}

TEST(Versioning, SkeletonSerialize) {
  // Open the file.
  const char* filename = OPTIONS_file;
  vox::io::File file(filename, "rb");
  ASSERT_TRUE(file.opened());

  // Open archive and test object tag.
  vox::io::IArchive archive(&file);
  ASSERT_TRUE(archive.TestTag<vox::animation::Skeleton>());

  // Read the object.
  vox::animation::Skeleton skeleton;
  archive >> skeleton;

  // More testing
  EXPECT_EQ(skeleton.num_joints(), OPTIONS_joints);
  if (skeleton.num_joints()) {
    EXPECT_STREQ(skeleton.joint_names()[0], OPTIONS_root_name);
  }
}
