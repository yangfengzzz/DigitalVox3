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

#ifndef VOX_VOX_BASE_MEMORY_UNIQUE_PTR_H_
#define VOX_VOX_BASE_MEMORY_UNIQUE_PTR_H_

#include "memory/allocator.h"

#include <memory>
#include <utility>

namespace vox {

// Defaut deleter for vox unique_ptr, uses redirected memory allocator.
template <typename _Ty>
struct Deleter {
  Deleter() {}

  template <class _Up>
  Deleter(const Deleter<_Up>&, _Ty* = nullptr) {}

  void operator()(_Ty* _ptr) const {
    vox::Delete(_ptr);
  }
};

// Defines vox::unique_ptr to use vox default deleter.
template <typename _Ty, typename _Deleter = vox::Deleter<_Ty>>
using unique_ptr = std::unique_ptr<_Ty, _Deleter>;

// Implements make_unique to use vox redirected memory allocator.
template <typename _Ty, typename... _Args>
unique_ptr<_Ty> make_unique(_Args&&... _args) {
  return unique_ptr<_Ty>(New<_Ty>(std::forward<_Args>(_args)...));
}
}  // namespace vox
#endif  // VOX_VOX_BASE_MEMORY_UNIQUE_PTR_H_
