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

#include "log.h"

#include "gtest.h"
#include "gtest_helper.h"

int TestFunction(std::ostream& _stream, const char* _log) {
  _stream << _log << std::endl;
  return 46;
}

void TestLogLevel(vox::log::Level _level) {
  vox::log::SetLevel(_level);

  EXPECT_LOG_LOGV(TestFunction(vox::log::LogV(), "logv"), "logv");
  EXPECT_LOG_LOG(TestFunction(vox::log::Log(), "log"), "log");
  EXPECT_LOG_OUT(TestFunction(vox::log::Out(), "out"), "out");
  EXPECT_LOG_ERR(TestFunction(vox::log::Err(), "err"), "err");

  EXPECT_EQ_LOG_LOGV(TestFunction(vox::log::LogV(), "logv"), 46, "logv");
  EXPECT_EQ_LOG_LOG(TestFunction(vox::log::Log(), "log"), 46, "log");
  EXPECT_EQ_LOG_OUT(TestFunction(vox::log::Out(), "out"), 46, "out");
  EXPECT_EQ_LOG_ERR(TestFunction(vox::log::Err(), "err"), 46, "err");
}

TEST(Silent, Log) { TestLogLevel(vox::log::kSilent); }

TEST(Standard, Log) { TestLogLevel(vox::log::kStandard); }

TEST(Verbose, Log) { TestLogLevel(vox::log::kVerbose); }

TEST(FloatPrecision, Log) {
  const float number = 46.9352099f;
  vox::log::Log log;

  vox::log::FloatPrecision mod0(log, 0);
  EXPECT_LOG_LOG(log << number << '-' << std::endl, "47-");
  {
    vox::log::FloatPrecision mod2(log, 2);
    EXPECT_LOG_LOG(log << number << '-' << std::endl, "46.94-");
  }
  EXPECT_LOG_LOG(log << number << '-' << std::endl, "47-");
}
