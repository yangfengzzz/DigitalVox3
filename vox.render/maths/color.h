//
//  color.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/24.
//

#ifndef color_hpp
#define color_hpp

#include <cassert>
#include <cmath>
#include <array>
#include "maths/math_constant.h"
#include "platform.h"

namespace ozz {
namespace math {
/**
 * Modify a value from the gamma space to the linear space.
 * @param value - The value in gamma space
 * @returns The value in linear space
 */
OZZ_INLINE float gammaToLinearSpace(float value) {
    // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_framebuffer_sRGB.txt
    // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_texture_sRGB_decode.txt
    
    if (value <= 0.0) return 0.0;
    else if (value <= 0.04045) return value / 12.92;
    else if (value < 1.0) return std::pow((value + 0.055) / 1.055, 2.4);
    else return std::pow(value, 2.4);
}

/**
 * Modify a value from the linear space to the gamma space.
 * @param value - The value in linear space
 * @returns The value in gamma space
 */
OZZ_INLINE float linearToGammaSpace(float value) {
    // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_framebuffer_sRGB.txt
    // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_texture_sRGB_decode.txt
    
    if (value <= 0.0) return 0.0;
    else if (value < 0.0031308) return 12.92 * value;
    else if (value < 1.0) return 1.055 * std::pow(value, 0.41666) - 0.055;
    else return std::pow(value, 0.41666);
}

struct Color {
    /** The red component of the color, 0~1. */
    float r;
    /** The green component of the color, 0~1. */
    float g;
    /** The blue component of the color, 0~1. */
    float b;
    /** The alpha component of the color, 0~1. */
    float a;
    
    Color(float r = 1, float g = 1, float b = 1, float a = 1) :
    r(r), g(g), b(b), a(a) {
    }
    
    /**
     * Modify components (r, g, b) of this color from gamma space to linear space.
     * @returns The color in linear space
     */
    OZZ_INLINE Color toLinear() {
        Color out = *this;
        out.r = gammaToLinearSpace(r);
        out.g = gammaToLinearSpace(g);
        out.b = gammaToLinearSpace(b);
        return out;
    }
    
    /**
     * Modify components (r, g, b) of this color from linear space to gamma space.
     * @returns The color in gamma space
     */
    OZZ_INLINE Color toGamma() {
        Color out = *this;
        out.r = linearToGammaSpace(r);
        out.g = linearToGammaSpace(g);
        out.b = linearToGammaSpace(b);
        return out;
    }
};

OZZ_INLINE bool operator==(const Color &left, const Color &right) {
    return (
            (left.r == right.r) &&
            (left.g == right.g) &&
            (left.b == right.b) &&
            (left.a == right.a)
            );
}

OZZ_INLINE Color operator+(const Color &left, const Color &right) {
    return Color(left.r + right.r,
                 left.g + right.g,
                 left.b + right.b,
                 left.a + right.a);
}

OZZ_INLINE Color operator+(const Color &left, const float s) {
    return Color(left.r * s,
                 left.g * s,
                 left.b * s,
                 left.a * s);
}

}
}
#endif /* color_hpp */
