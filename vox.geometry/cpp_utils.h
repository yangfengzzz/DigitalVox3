// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_CPP_UTILS_H_
#define INCLUDE_JET_CPP_UTILS_H_

#include <algorithm>

namespace vox {
namespace geometry {

template <class ForwardIt, class T, class Compare = std::less<T>>
ForwardIt binaryFind(ForwardIt first, ForwardIt last, const T &value, Compare comp = {});
} // namespace vox
} // namespace geometry

#include "cpp_utils-inl.h"

#endif // INCLUDE_JET_CPP_UTILS_H_
