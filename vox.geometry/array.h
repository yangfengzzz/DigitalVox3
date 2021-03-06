// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_ARRAY_H_
#define INCLUDE_JET_ARRAY_H_

#include "matrix.h"
#include "nested_initializer_list.h"

#include <algorithm>
#include <functional>
#include <vector>

namespace vox {
namespace geometry {

// MARK: ArrayBase

template <typename T, size_t N, typename DerivedArray> class ArrayBase {
public:
  using Derived = DerivedArray;
  using value_type = T;
  using reference = T &;
  using const_reference = const T &;
  using pointer = T *;
  using const_pointer = const T *;
  using iterator = T *;
  using const_iterator = const T *;

  virtual ~ArrayBase() = default;

  size_t index(size_t i) const;

  template <typename... Args> size_t index(size_t i, Args... args) const;

  template <size_t... I> size_t index(const Vector<size_t, N> &idx) const;

  pointer data();

  const_pointer data() const;

  const Vector<size_t, N> &size() const;

  template <size_t M = N> std::enable_if_t<(M > 0), size_t> width() const;

  template <size_t M = N> std::enable_if_t<(M > 1), size_t> height() const;

  template <size_t M = N> std::enable_if_t<(M > 2), size_t> depth() const;

  bool isEmpty() const;

  size_t length() const;

  iterator begin();

  const_iterator begin() const;

  iterator end();

  const_iterator end() const;

  iterator rbegin();

  const_iterator rbegin() const;

  iterator rend();

  const_iterator rend() const;

  reference at(size_t i);

  const_reference at(size_t i) const;

  template <typename... Args> reference at(size_t i, Args... args);

  template <typename... Args> const_reference at(size_t i, Args... args) const;

  reference at(const Vector<size_t, N> &idx);

  const_reference at(const Vector<size_t, N> &idx) const;

  reference operator[](size_t i);

  const_reference operator[](size_t i) const;

  template <typename... Args> reference operator()(size_t i, Args... args);

  template <typename... Args> const_reference operator()(size_t i, Args... args) const;

  reference operator()(const Vector<size_t, N> &idx);

  const_reference operator()(const Vector<size_t, N> &idx) const;

  template <typename Callback> void forEach(Callback func) const {
    if constexpr (N == 1) {
      for (size_t i = 0; i < _size.x; ++i) {
        func(at(i));
      }
    } else if constexpr (N == 2) {
      for (size_t j = 0; j < _size.y; ++j) {
        for (size_t i = 0; i < _size.x; ++i) {
          func(at(i, j));
        }
      }
    } else if constexpr (N == 3) {
      for (size_t k = 0; k < _size.z; ++k) {
        for (size_t j = 0; j < _size.y; ++j) {
          for (size_t i = 0; i < _size.x; ++i) {
            func(at(i, j, k));
          }
        }
      }
    }
  }

  template <typename Callback> void forEachIndex(Callback func) const {
    if constexpr (N == 1) {
      for (size_t i = 0; i < _size.x; ++i) {
        func(i);
      }
    } else if constexpr (N == 2) {
      for (size_t j = 0; j < _size.y; ++j) {
        for (size_t i = 0; i < _size.x; ++i) {
          func(i, j);
        }
      }
    } else if constexpr (N == 3) {
      for (size_t k = 0; k < _size.z; ++k) {
        for (size_t j = 0; j < _size.y; ++j) {
          for (size_t i = 0; i < _size.x; ++i) {
            func(i, j, k);
          }
        }
      }
    }
  }

  template <typename Callback> void parallelForEach(Callback func) {
    if constexpr (N == 1) {
      parallelFor(kZeroSize, _size.x, [&](size_t i) { func(at(i)); });
    } else if constexpr (N == 2) {
      parallelFor(kZeroSize, _size.x, kZeroSize, _size.y, [&](size_t i, size_t j) { func(at(i, j)); });
    } else if constexpr (N == 3) {
      parallelFor(kZeroSize, _size.x, kZeroSize, _size.y, kZeroSize, _size.z,
                  [&](size_t i, size_t j, size_t k) { func(at(i, j, k)); });
    }
  }

  template <typename Callback> void parallelForEachIndex(Callback func) const {
    if constexpr (N == 1) {
      parallelFor(kZeroSize, _size.x, [&](size_t i) { func(i); });
    } else if constexpr (N == 2) {
      parallelFor(kZeroSize, _size.x, kZeroSize, _size.y, [&](size_t i, size_t j) { func(i, j); });
    } else if constexpr (N == 3) {
      parallelFor(kZeroSize, _size.x, kZeroSize, _size.y, kZeroSize, _size.z,
                  [&](size_t i, size_t j, size_t k) { func(i, j, k); });
    }
  }

protected:
  pointer _ptr = nullptr;
  Vector<size_t, N> _size;

  ArrayBase();

  ArrayBase(const ArrayBase &other);

  ArrayBase(ArrayBase &&other) noexcept;

  template <typename... Args> void setPtrAndSize(pointer ptr, size_t ni, Args... args);

  void setPtrAndSize(pointer data, Vector<size_t, N> size);

  void swapPtrAndSize(ArrayBase &other);

  void clearPtrAndSize();

  ArrayBase &operator=(const ArrayBase &other);

  ArrayBase &operator=(ArrayBase &&other);

private:
  template <typename... Args> size_t _index(size_t d, size_t i, Args... args) const;

  size_t _index(size_t, size_t i) const;

  template <size_t... I> size_t _index(const Vector<size_t, N> &idx, std::index_sequence<I...>) const;
};

// MARK: Array

template <typename T, size_t N> class ArrayView;

template <typename T, size_t N> class Array final : public ArrayBase<T, N, Array<T, N>> {
  using Base = ArrayBase<T, N, Array<T, N>>;
  using Base::_size;
  using Base::at;
  using Base::clearPtrAndSize;
  using Base::setPtrAndSize;
  using Base::swapPtrAndSize;

public:
  // CTOR
  Array();

  Array(const Vector<size_t, N> &size_, const T &initVal = T{});

  template <typename... Args> Array(size_t nx, Args... args);

  Array(NestedInitializerListsT<T, N> lst);

  template <typename OtherDerived> Array(const ArrayBase<T, N, OtherDerived> &other);

  template <typename OtherDerived> Array(const ArrayBase<const T, N, OtherDerived> &other);

  Array(const Array &other);

  Array(Array &&other) noexcept;

  template <typename D> void copyFrom(const ArrayBase<T, N, D> &other);

  template <typename D> void copyFrom(const ArrayBase<const T, N, D> &other);

  void fill(const T &val);

  // resize
  void resize(Vector<size_t, N> size_, const T &initVal = T{});

  template <typename... Args> void resize(size_t nx, Args... args);

  template <size_t M = N> std::enable_if_t<(M == 1), void> append(const T &val);

  template <typename OtherDerived, size_t M = N>
  std::enable_if_t<(M == 1), void> append(const ArrayBase<T, N, OtherDerived> &extra);

  template <typename OtherDerived, size_t M = N>
  std::enable_if_t<(M == 1), void> append(const ArrayBase<const T, N, OtherDerived> &extra);

  void clear();

  void swap(Array &other);

  // Views
  ArrayView<T, N> view();

  ArrayView<const T, N> view() const;

  // Assignment Operators
  template <typename OtherDerived> Array &operator=(const ArrayBase<T, N, OtherDerived> &other);

  template <typename OtherDerived> Array &operator=(const ArrayBase<const T, N, OtherDerived> &other);

  Array &operator=(const Array &other);

  Array &operator=(Array &&other);

private:
  std::vector<T> _data;
};

template <class T> using Array1 = Array<T, 1>;

template <class T> using Array2 = Array<T, 2>;

template <class T> using Array3 = Array<T, 3>;

template <class T> using Array4 = Array<T, 4>;

} // namespace vox
} // namespace geometry

#include "array-inl.h"

#endif // INCLUDE_JET_ARRAY_H_
