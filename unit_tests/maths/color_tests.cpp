//
//  color_tests.cpp
//  unit_tests
//
//  Created by 杨丰 on 2021/11/26.
//

#include "maths/color.h"

#include "gtest.h"

#include "gtest_helper.h"
#include "gtest_math_helper.h"
#include <random>

using ozz::math::Color;

TEST(Color, Constructor) {
    const auto color1 = Color(1, 0.5, 0.5, 1);
    auto color2 = Color();
    color2.r = 1;
    color2.g = 0.5;
    color2.b = 0.5;
    color2.a = 1;
    
    EXPECT_EQ(color1, color2);
}

TEST(Color, scale) {
    auto color1 = Color(0.5, 0.5, 0.5, 0.5);
    auto color2 = Color(1, 1, 1, 1);
    
    color1 = color1 * 2.0;
    EXPECT_EQ(color1, color2);
    
    color2 = color1 * 0.5;
    EXPECT_COLOR_EQ(color2, 0.5, 0.5, 0.5, 0.5);
}

TEST(Color, add) {
    auto color1 = Color(1, 0, 0, 0);
    auto color2 = Color(0, 1, 0, 0);
    
    color1 = color1 + color2;
    EXPECT_COLOR_EQ(color1, 1, 1, 0, 0);
    
    color2 = color1 + Color(0, 0, 1, 0);
    EXPECT_COLOR_EQ(color2, 1, 1, 1, 0);
}

TEST(Color, LinearAndGamma) {
    const auto fixColor = [](Color &color) {
        color.r = std::floor(color.r * 1000) / 1000;
        color.g = std::floor(color.g * 1000) / 1000;
        color.b = std::floor(color.b * 1000) / 1000;
    };
    
    auto colorLinear = Color();
    auto colorGamma = Color();
    auto colorNewLinear = Color();
    
    std::default_random_engine e;
    std::uniform_real_distribution<float> u(0.0, 1.0);
    
    for (int i = 0; i < 100; ++i) {
        colorLinear.r = u(e);
        colorLinear.g = u(e);
        colorLinear.b = u(e);
        fixColor(colorLinear);
        
        colorGamma = colorLinear.toGamma();
        colorNewLinear = colorGamma.toLinear();
        
        fixColor(colorLinear);
        fixColor(colorNewLinear);
        
        EXPECT_COLOR_EQ(colorLinear, colorNewLinear.r, colorNewLinear.g, colorNewLinear.b, colorNewLinear.a);
    }
}
