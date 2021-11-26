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

#include <stdint.h>

#include "gtest.h"
#include "gtest_helper.h"
#include "span.h"

TEST(Span, Platform) {
  const size_t kSize = 46;
  int i = 20;
  int ai[kSize];
  const size_t array_size = VOX_ARRAY_SIZE(ai);

  vox::span<int> empty;
  EXPECT_TRUE(empty.begin() == nullptr);
  EXPECT_EQ(empty.size(), 0u);
  EXPECT_EQ(empty.size_bytes(), 0u);

  EXPECT_ASSERTION(empty[46], "Index out of range.");

  vox::span<int> single(i);
  EXPECT_TRUE(single.begin() == &i);
  EXPECT_EQ(single.size(), 1u);
  EXPECT_EQ(single.size_bytes(), sizeof(i));

  EXPECT_ASSERTION(single[46], "Index out of range.");

  vox::span<int> cs1(ai, ai + array_size);
  EXPECT_EQ(cs1.begin(), ai);
  EXPECT_EQ(cs1.size(), array_size);
  EXPECT_EQ(cs1.size_bytes(), sizeof(ai));

  // Re-inint
  vox::span<int> reinit;
  reinit = ai;
  EXPECT_EQ(reinit.begin(), ai);
  EXPECT_EQ(reinit.size(), array_size);
  EXPECT_EQ(reinit.size_bytes(), sizeof(ai));

  // Clear
  reinit = {};
  EXPECT_EQ(reinit.size(), 0u);
  EXPECT_EQ(reinit.size_bytes(), 0u);

  cs1[12] = 46;
  EXPECT_EQ(cs1[12], 46);
  EXPECT_ASSERTION(cs1[46], "Index out of range.");

  vox::span<int> cs2(ai, array_size);
  EXPECT_EQ(cs2.begin(), ai);
  EXPECT_EQ(cs2.size(), array_size);
  EXPECT_EQ(cs2.size_bytes(), sizeof(ai));

  vox::span<int> carray(ai);
  EXPECT_EQ(carray.begin(), ai);
  EXPECT_EQ(carray.size(), array_size);
  EXPECT_EQ(carray.size_bytes(), sizeof(ai));

  vox::span<int> copy(cs2);
  EXPECT_EQ(cs2.begin(), copy.begin());
  EXPECT_EQ(cs2.size_bytes(), copy.size_bytes());

  vox::span<const int> const_copy(cs2);
  EXPECT_EQ(cs2.begin(), const_copy.begin());
  EXPECT_EQ(cs2.size_bytes(), const_copy.size_bytes());

  EXPECT_EQ(cs2[12], 46);
  EXPECT_ASSERTION(cs2[46], "Index out of range.");

  // Invalid range
  EXPECT_ASSERTION(vox::span<int>(ai, ai - array_size), "Invalid range.");
}

TEST(SpanAsBytes, Platform) {
  const size_t kSize = 46;
  int ai[kSize];
  {
    vox::span<int> si(ai);
    EXPECT_EQ(si.size(), kSize);

    vox::span<const char> ab = as_bytes(si);
    EXPECT_EQ(ab.size(), kSize * sizeof(int));

    vox::span<char> awb = as_writable_bytes(si);
    EXPECT_EQ(awb.size(), kSize * sizeof(int));
  }

  {  // mutable char
    char ac[kSize];
    vox::span<char> sc(ac);
    EXPECT_EQ(sc.size(), kSize);

    vox::span<const char> ab = as_bytes(sc);
    EXPECT_EQ(ab.size(), sc.size());

    vox::span<char> awbc = as_writable_bytes(sc);
    EXPECT_EQ(awbc.size(), sc.size());
  }
  {  // const
    vox::span<const int> si(ai);
    EXPECT_EQ(si.size(), kSize);

    vox::span<const char> ab = as_bytes(si);
    EXPECT_EQ(ab.size(), kSize * sizeof(int));
  }

  // const char
  {
    const char ac[kSize] = {};
    vox::span<const char> sc(ac);
    EXPECT_EQ(sc.size(), kSize);

    vox::span<const char> ab = as_bytes(sc);
    EXPECT_EQ(ab.size(), sc.size());
  }
}

TEST(SpanFill, Platform) {
  alignas(alignof(int)) char abuffer[16];
  vox::span<char> src(abuffer);

  vox::span<int> ispan1 = vox::fill_span<int>(src, 3);
  EXPECT_EQ(ispan1.size(), 3u);
  vox::span<int> ispan2 = vox::fill_span<int>(src, 1);
  EXPECT_EQ(ispan2.size(), 1u);
  EXPECT_TRUE(src.empty());
  EXPECT_ASSERTION(vox::fill_span<int>(src, 1), "Invalid range.");

  // Bad aligment
  src = vox::make_span(abuffer);

  vox::span<char> cspan = vox::fill_span<char>(src, 1);
  EXPECT_EQ(cspan.size(), 1u);
  EXPECT_ASSERTION(vox::fill_span<int>(src, 1), "Invalid alignment.");
}

TEST(SpanRangeLoop, Platform) {
  const size_t kSize = 46;
  size_t ai[kSize];

  // non const
  vox::span<size_t> si = vox::make_span(ai);
  size_t i = 0;
  for (size_t& li : si) {
    li = i++;
  }

  EXPECT_EQ(i, kSize);

  // const
  vox::span<const size_t> sci = si;
  i = 0;
  for (const size_t& li : sci) {
    EXPECT_EQ(i, li);
    i++;
  }
}
