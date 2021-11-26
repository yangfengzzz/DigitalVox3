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

#include "maths/math_constant.h"
#include "maths/math_ex.h"

#include "gtest.h"

#include "gtest_helper.h"

TEST(Trigonometry, vox_math_ex) {
    EXPECT_FLOAT_EQ(vox::math::kPi, 3.1415926535897932384626433832795f);
    EXPECT_FLOAT_EQ(vox::math::kPi * vox::math::kRadianToDegree, 180.f);
    EXPECT_FLOAT_EQ(180.f * vox::math::kDegreeToRadian, vox::math::kPi);
}

TEST(FloatArithmetic, vox_math_ex) {
    EXPECT_FLOAT_EQ(vox::math::Lerp(0.f, 1.f, 0.f), 0.f);
    EXPECT_FLOAT_EQ(vox::math::Lerp(0.f, 1.f, 1.f), 1.f);
    EXPECT_FLOAT_EQ(vox::math::Lerp(0.f, 1.f, .3f), .3f);
    EXPECT_FLOAT_EQ(vox::math::Lerp(0.f, 1.f, 12.f), 12.f);
    EXPECT_FLOAT_EQ(vox::math::Lerp(0.f, 1.f, -12.f), -12.f);
}

TEST(FloatComparison, vox_math_ex) {
    const float a = {.5f};
    const float b = {4.f};
    const float c = {2.f};
    
    const float min = vox::math::Min(a, b);
    EXPECT_FLOAT_EQ(min, a);
    
    const float max = vox::math::Max(a, b);
    EXPECT_FLOAT_EQ(max, b);
    
    const float clamp = vox::math::Clamp(a, c, b);
    EXPECT_FLOAT_EQ(clamp, c);
    
    const float clamp0 = vox::math::Clamp(a, b, c);
    EXPECT_FLOAT_EQ(clamp0, c);
    
    const float clamp1 = vox::math::Clamp(c, a, b);
    EXPECT_FLOAT_EQ(clamp1, c);
}

TEST(Select, vox_math_ex) {
    int a = -27, b = 46;
    int *pa = &a, *pb = &b;
    int *cpa = &a, *cpb = &b;
    
    {  // Integer select
        EXPECT_EQ(vox::math::Select(true, a, b), a);
        EXPECT_EQ(vox::math::Select(true, b, a), b);
        EXPECT_EQ(vox::math::Select(false, a, b), b);
    }
    
    {  // Float select
        EXPECT_FLOAT_EQ(vox::math::Select(true, 46.f, 27.f), 46.f);
        EXPECT_FLOAT_EQ(vox::math::Select(false, 99.f, 46.f), 46.f);
    }
    
    {  // Pointer select
        EXPECT_EQ(vox::math::Select(true, pa, pb), pa);
        EXPECT_EQ(vox::math::Select(true, pb, pa), pb);
        EXPECT_EQ(vox::math::Select(false, pa, pb), pb);
    }
    
    {  // Const pointer select
        EXPECT_EQ(vox::math::Select(true, cpa, cpb), cpa);
        EXPECT_EQ(vox::math::Select(true, cpb, cpa), cpb);
        EXPECT_EQ(vox::math::Select(false, cpa, cpb), cpb);
        EXPECT_EQ(vox::math::Select(false, pa, cpb), cpb);
    }
}
