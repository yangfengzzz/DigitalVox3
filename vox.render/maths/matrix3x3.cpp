//
//  matrix3x3.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/24.
//

#include "matrix3x3.h"
#include "matrix.h"

namespace ozz {
namespace math {
OZZ_INLINE Matrix3x3 normalMatrix(const Matrix &mat4) {
    const auto &ae = mat4.elements;
    const auto &a11 = ae[0],
    a12 = ae[1],
    a13 = ae[2],
    a14 = ae[3];
    const auto &a21 = ae[4],
    a22 = ae[5],
    a23 = ae[6],
    a24 = ae[7];
    const auto &a31 = ae[8],
    a32 = ae[9],
    a33 = ae[10],
    a34 = ae[11];
    const auto &a41 = ae[12],
    a42 = ae[13],
    a43 = ae[14],
    a44 = ae[15];
    
    const auto b00 = a11 * a22 - a12 * a21;
    const auto b01 = a11 * a23 - a13 * a21;
    const auto b02 = a11 * a24 - a14 * a21;
    const auto b03 = a12 * a23 - a13 * a22;
    const auto b04 = a12 * a24 - a14 * a22;
    const auto b05 = a13 * a24 - a14 * a23;
    const auto b06 = a31 * a42 - a32 * a41;
    const auto b07 = a31 * a43 - a33 * a41;
    const auto b08 = a31 * a44 - a34 * a41;
    const auto b09 = a32 * a43 - a33 * a42;
    const auto b10 = a32 * a44 - a34 * a42;
    const auto b11 = a33 * a44 - a34 * a43;
    
    auto det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
    if (!det) {
        return Matrix3x3();
    }
    det = 1.0 / det;
    
    return Matrix3x3((a22 * b11 - a23 * b10 + a24 * b09) * det,
                     (a23 * b08 - a21 * b11 - a24 * b07) * det,
                     (a21 * b10 - a22 * b08 + a24 * b06) * det,
                     
                     (a13 * b10 - a12 * b11 - a14 * b09) * det,
                     (a11 * b11 - a13 * b08 + a14 * b07) * det,
                     (a12 * b08 - a11 * b10 - a14 * b06) * det,
                     
                     (a42 * b05 - a43 * b04 + a44 * b03) * det,
                     (a43 * b02 - a41 * b05 - a44 * b01) * det,
                     (a41 * b04 - a42 * b02 + a44 * b00) * det);
}

}
}
