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
#include "maths/simd_math.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

TEST(BoxValidity, vox_math) {
    EXPECT_FALSE(vox::math::BoundingBox().is_valid());
    EXPECT_FALSE(vox::math::BoundingBox(vox::math::Float3(0.f, 1.f, 2.f),
                                        vox::math::Float3(0.f, -1.f, 2.f))
                 .is_valid());
    EXPECT_TRUE(vox::math::BoundingBox(vox::math::Float3(0.f, -1.f, 2.f),
                                       vox::math::Float3(0.f, 1.f, 2.f))
                .is_valid());
    EXPECT_TRUE(vox::math::BoundingBox(vox::math::Float3(0.f, 1.f, 2.f),
                                       vox::math::Float3(0.f, 1.f, 2.f))
                .is_valid());
}

TEST(BoxInside, vox_math) {
    const vox::math::BoundingBox invalid(vox::math::Float3(0.f, 1.f, 2.f),
                                         vox::math::Float3(0.f, -1.f, 2.f));
    EXPECT_FALSE(invalid.is_valid());
    EXPECT_FALSE(invalid.is_inside(vox::math::Float3(0.f, 1.f, 2.f)));
    EXPECT_FALSE(invalid.is_inside(vox::math::Float3(0.f, -.5f, 2.f)));
    EXPECT_FALSE(invalid.is_inside(vox::math::Float3(-1.f, -2.f, -3.f)));
    
    const vox::math::BoundingBox valid(vox::math::Float3(-1.f, -2.f, -3.f),
                                       vox::math::Float3(1.f, 2.f, 3.f));
    EXPECT_TRUE(valid.is_valid());
    EXPECT_FALSE(valid.is_inside(vox::math::Float3(0.f, -3.f, 0.f)));
    EXPECT_FALSE(valid.is_inside(vox::math::Float3(0.f, 3.f, 0.f)));
    EXPECT_TRUE(valid.is_inside(vox::math::Float3(-1.f, -2.f, -3.f)));
    EXPECT_TRUE(valid.is_inside(vox::math::Float3(0.f, 0.f, 0.f)));
}

TEST(BoxMerge, vox_math) {
    const vox::math::BoundingBox invalid1(vox::math::Float3(0.f, 1.f, 2.f),
                                          vox::math::Float3(0.f, -1.f, 2.f));
    EXPECT_FALSE(invalid1.is_valid());
    const vox::math::BoundingBox invalid2(vox::math::Float3(0.f, -1.f, 2.f),
                                          vox::math::Float3(0.f, 1.f, -2.f));
    EXPECT_FALSE(invalid2.is_valid());
    
    const vox::math::BoundingBox valid1(vox::math::Float3(-1.f, -2.f, -3.f),
                                        vox::math::Float3(1.f, 2.f, 3.f));
    EXPECT_TRUE(valid1.is_valid());
    const vox::math::BoundingBox valid2(vox::math::Float3(0.f, 5.f, -8.f),
                                        vox::math::Float3(1.f, 6.f, 0.f));
    EXPECT_TRUE(valid2.is_valid());
    
    // Both boxes are invalid.
    EXPECT_FALSE(Merge(invalid1, invalid2).is_valid());
    
    // One box is invalid.
    EXPECT_TRUE(Merge(invalid1, valid1).is_valid());
    EXPECT_TRUE(Merge(valid1, invalid1).is_valid());
    
    // Both boxes are valid.
    const vox::math::BoundingBox merge = Merge(valid1, valid2);
    EXPECT_FLOAT3_EQ(merge.min, -1.f, -2.f, -8.f);
    EXPECT_FLOAT3_EQ(merge.max, 1.f, 6.f, 3.f);
}

TEST(BoxTransform, vox_math) {
    const vox::math::BoundingBox a(vox::math::Float3(1.f, 2.f, 3.f),
                                   vox::math::Float3(4.f, 5.f, 6.f));
    
    const vox::math::BoundingBox ia = TransformBox(vox::math::Float4x4::identity(), a);
    EXPECT_FLOAT3_EQ(ia.min, 1.f, 2.f, 3.f);
    EXPECT_FLOAT3_EQ(ia.max, 4.f, 5.f, 6.f);
    
    const vox::math::BoundingBox ta =
    TransformBox(vox::math::Float4x4::Translation(vox::math::simd_float4::Load(2.f, -2.f, 3.f, 0.f)), a);
    EXPECT_FLOAT3_EQ(ta.min, 3.f, 0.f, 6.f);
    EXPECT_FLOAT3_EQ(ta.max, 6.f, 3.f, 9.f);
    
    const vox::math::BoundingBox ra =
    TransformBox(vox::math::Float4x4::FromAxisAngle(vox::math::simd_float4::y_axis(),
                                                    vox::math::simd_float4::LoadX(vox::math::kPi)), a);
    EXPECT_FLOAT3_EQ(ra.min, -4.f, 2.f, -6.f);
    EXPECT_FLOAT3_EQ(ra.max, -1.f, 5.f, -3.f);
}

TEST(BoxBuild, vox_math) {
    const struct {
        vox::math::Float3 value;
        char pad;
    } points[] = {
        {vox::math::Float3(0.f, 0.f, 0.f), 0},
        {vox::math::Float3(1.f, -1.f, 0.f), 0},
        {vox::math::Float3(0.f, 0.f, 46.f), 0},
        {vox::math::Float3(-27.f, 0.f, 0.f), 0},
        {vox::math::Float3(0.f, 58.f, 0.f), 0},
    };
    
    // Builds from a single point
    const vox::math::BoundingBox single_valid(points[1].value);
    EXPECT_TRUE(single_valid.is_valid());
    EXPECT_FLOAT3_EQ(single_valid.min, 1.f, -1.f, 0.f);
    EXPECT_FLOAT3_EQ(single_valid.max, 1.f, -1.f, 0.f);
    
    // Builds from multiple points
    EXPECT_ASSERTION(vox::math::BoundingBox(&points->value, 1, VOX_ARRAY_SIZE(points)),
                     "_stride must be greater or equal to sizeof\\(Float3\\)");
    
    const vox::math::BoundingBox multi_invalid(&points->value, sizeof(points[0]), 0);
    EXPECT_FALSE(multi_invalid.is_valid());
    
    const vox::math::BoundingBox multi_valid(&points->value, sizeof(points[0]),
                                             VOX_ARRAY_SIZE(points));
    EXPECT_TRUE(multi_valid.is_valid());
    EXPECT_FLOAT3_EQ(multi_valid.min, -27.f, -1.f, 0.f);
    EXPECT_FLOAT3_EQ(multi_valid.max, 1.f, 58.f, 46.f);
}
