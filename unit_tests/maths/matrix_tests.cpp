//
//  matrix_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/25.
//

#include "maths/matrix.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"

using ozz::math::Matrix;

TEST(Matrix, multiply) {
    const auto a = Matrix(1, 2, 3.3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 13, 14, 15, 16);
    const auto b = Matrix(16, 15, 14, 13, 12, 11, 10, 9, 8.88, 7, 6, 5, 4, 3, 2, 1);
    const Matrix out = a * b;
    EXPECT_MATRIX_EQ(out,
                     386,
                     456.59997558,
                     506.8,
                     560,
                     274,
                     325,
                     361.6,
                     400,
                     162.88,
                     195.16000000000003,
                     219.304,
                     243.52,
                     50,
                     61.8,
                     71.2,
                     80);
}
