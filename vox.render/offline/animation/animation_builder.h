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

#ifndef VOX_VOX_ANIMATION_OFFLINE_ANIMATION_BUILDER_H_
#define VOX_VOX_ANIMATION_OFFLINE_ANIMATION_BUILDER_H_

#include "memory/unique_ptr.h"

namespace vox {
namespace animation {

// Forward declares the runtime animation type.
class Animation;

namespace offline {

// Forward declares the offline animation type.
struct RawAnimation;

// Defines the class responsible of building runtime animation instances from
// offline raw animations.
// No optimization at all is performed on the raw animation.
class AnimationBuilder {
 public:
  // Creates an Animation based on _raw_animation and *this builder parameters.
  // Returns a valid Animation on success.
  // See RawAnimation::Validate() for more details about failure reasons.
  // The animation is returned as an unique_ptr as ownership is given back to
  // the caller.
  unique_ptr<Animation> operator()(const RawAnimation& _raw_animation) const;
};
}  // namespace offline
}  // namespace animation
}  // namespace vox
#endif  // VOX_VOX_ANIMATION_OFFLINE_ANIMATION_BUILDER_H_
