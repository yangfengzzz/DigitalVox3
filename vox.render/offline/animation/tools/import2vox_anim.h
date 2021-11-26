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

#ifndef VOX_ANIMATION_OFFLINE_TOOLS_IMPORT2VOX_ANIM_H_
#define VOX_ANIMATION_OFFLINE_TOOLS_IMPORT2VOX_ANIM_H_

#include "endianness.h"
#include "platform.h"

#include "import2vox_config.h"
#include "offline/animation/tools/import2vox.h"

namespace Json {
class Value;
}

namespace vox {
namespace animation {
namespace offline {

class VoxImporter;
bool ImportAnimations(const Json::Value& _config, VoxImporter* _importer,
                      const vox::Endianness _endianness);

// Additive reference enum to config string conversions.
struct AdditiveReferenceEnum {
  enum Value { kAnimation, kSkeleton };
};
struct AdditiveReference
    : JsonEnum<AdditiveReference, AdditiveReferenceEnum::Value> {
  static EnumNames GetNames();
};
}  // namespace offline
}  // namespace animation
}  // namespace vox
#endif  // VOX_ANIMATION_OFFLINE_TOOLS_IMPORT2VOX_ANIM_H_
