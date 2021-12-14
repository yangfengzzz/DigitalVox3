// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_DETAIL_CPP_UTILS_INL_H_
#define INCLUDE_JET_DETAIL_CPP_UTILS_INL_H_

#include "cpp_utils.h"

namespace vox {
namespace geometry {

// Source code from:
// http://en.cppreference.com/w/cpp/algorithm/lower_bound
template <class ForwardIt, class T, class Compare>
ForwardIt binaryFind(ForwardIt first, ForwardIt last, const T &value, Compare comp) {
  // Note: BOTH type T and the type after ForwardIt is dereference
  // must be implicitly convertible to BOTH Type1 and Type2, used in Compare.
  // This is stricter than lower_bound requirement (see above)

  first = std::lower_bound(first, last, value, comp);
  return first != last && !comp(value, *first) ? first : last;
}
} // namespace vox
} // namespace geometry

#endif // INCLUDE_JET_DETAIL_CPP_UTILS_INL_H_
