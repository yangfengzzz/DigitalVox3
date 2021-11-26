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

#include "memory/unique_ptr.h"

#include "gtest_helper.h"

TEST(Construction, unique_ptr) {
  { const vox::unique_ptr<int> pi; }
  { const vox::unique_ptr<int> pi(vox::New<int>()); }
}

TEST(Reset, unique_ptr) {
  {
    vox::unique_ptr<int> pi;
    pi.reset(nullptr);

    pi.reset(vox::New<int>());
  }
  {
    vox::unique_ptr<int> pi(vox::New<int>());
    pi.reset(vox::New<int>());
    pi.reset(nullptr);
  }
}

struct A {
  int i;
};

TEST(Dereference, unique_ptr) {
  {
    const vox::unique_ptr<int> pi;
    EXPECT_TRUE(pi.get() == nullptr);
    EXPECT_FALSE(pi);
  }
  {
    const vox::unique_ptr<int> pi(vox::New<int>(46));
    EXPECT_EQ(*pi, 46);
    EXPECT_TRUE(pi.get() != nullptr);
    EXPECT_TRUE(pi);
  }
  {
    const vox::unique_ptr<A> pa(vox::New<A>());
    pa->i = 46;
    EXPECT_EQ((*pa).i, 46);
  }
}

TEST(Bool, unique_ptr) {
  {
    const vox::unique_ptr<int> pi;
    EXPECT_TRUE(!pi);
    EXPECT_FALSE(pi);
  }
  {
    const vox::unique_ptr<int> pi(vox::New<int>(46));
    EXPECT_FALSE(!pi);
    EXPECT_TRUE(pi);
  }
}

TEST(Swap, unique_ptr) {
  {
    int* i = vox::New<int>(46);
    vox::unique_ptr<int> pi;
    vox::unique_ptr<int> pii(i);
    EXPECT_TRUE(pi.get() == nullptr);
    EXPECT_TRUE(pii.get() == i);

    pi.swap(pii);
    EXPECT_TRUE(pii.get() == nullptr);
    EXPECT_TRUE(pi.get() == i);
  }
  {
    int* i = vox::New<int>(46);
    vox::unique_ptr<int> pi;
    vox::unique_ptr<int> pii(i);
    EXPECT_TRUE(pi.get() == nullptr);
    EXPECT_TRUE(pii.get() == i);

    swap(pi, pii);
    EXPECT_TRUE(pii.get() == nullptr);
    EXPECT_TRUE(pi.get() == i);
  }
}

TEST(Release, unique_ptr) {
  int* i = vox::New<int>(46);
  {
    vox::unique_ptr<int> pi(i);
    int* ri = pi.release();
    EXPECT_EQ(i, ri);
  }
  vox::Delete(i);
}

struct B : public A {};

TEST(Upcast, unique_ptr) {
  vox::unique_ptr<A> a = vox::unique_ptr<B>();
  a = vox::unique_ptr<B>();
}

TEST(make_unique, unique_ptr) {
  {  // No argument
    EXPECT_TRUE(vox::make_unique<int>());
    EXPECT_EQ(*vox::make_unique<int>(), 0);
  }

  {  // 1 argument
    EXPECT_TRUE(vox::make_unique<int>(46));
    EXPECT_EQ(*vox::make_unique<int>(46), 46);
  }

  {  // N arguments
    auto p5 =
        vox::make_unique<std::tuple<int, int, int, int, int>>(0, 1, 2, 3, 4);
    EXPECT_TRUE(p5);
    EXPECT_EQ(*p5, std::make_tuple(0, 1, 2, 3, 4));
  }
}
