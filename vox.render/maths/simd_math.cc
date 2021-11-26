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

#include "maths/simd_math.h"

namespace vox {
namespace math {

// Select compile time name of the simd implementation
#if defined(VOX_SIMD_AVX2) && defined(VOX_SIMD_FMA)
#define _VOX_SIMD_IMPLEMENTATION "AVX2-FMA"
#elif defined(VOX_SIMD_AVX2)
#define _VOX_SIMD_IMPLEMENTATION "AVX2"
#elif defined(VOX_SIMD_AVX)
#define _VOX_SIMD_IMPLEMENTATION "AVX"
#elif defined(VOX_SIMD_SSE4_2)
#define _VOX_SIMD_IMPLEMENTATION "SSE4.2"
#elif defined(VOX_SIMD_SSE4_1)
#define _VOX_SIMD_IMPLEMENTATION "SSE4.1"
#elif defined(VOX_SIMD_SSSE3)
#define _VOX_SIMD_IMPLEMENTATION "SSSE3"
#elif defined(VOX_SIMD_SSE3)
#define _VOX_SIMD_IMPLEMENTATION "SSE3"
#elif defined(VOX_SIMD_SSEx)
#define _VOX_SIMD_IMPLEMENTATION "SSE2"
#elif defined(VOX_SIMD_REF)
#define _VOX_SIMD_IMPLEMENTATION "Reference"
#else
// Not defined
#endif

#pragma message("Vox libraries were built with " _VOX_SIMD_IMPLEMENTATION \
                " SIMD math implementation")

const char* SimdImplementationName() { return _VOX_SIMD_IMPLEMENTATION; }
}  // namespace math
}  // namespace vox
