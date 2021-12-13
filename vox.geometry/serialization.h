// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_SERIALIZATION_H_
#define INCLUDE_JET_SERIALIZATION_H_

#include "array_view.h"

#include <vector>

namespace vox {

//! Abstract base class for any serializable class.
class Serializable {
public:
  //! Default constructor.
  Serializable() = default;

  //! Default copy constructor.
  Serializable(const Serializable &) = default;

  //! Default move constructor.
  Serializable(Serializable &&) noexcept = default;

  //! Default virtual destructor.
  virtual ~Serializable() = default;

  //! Default copy assignment operator.
  Serializable &operator=(const Serializable &) = default;

  //! Default move assignment operator.
  Serializable &operator=(Serializable &&) noexcept = default;

  //! Serializes this instance into the flat buffer.
  virtual void serialize(std::vector<uint8_t> *buffer) const = 0;

  //! Deserializes this instance from the flat buffer.
  virtual void deserialize(const std::vector<uint8_t> &buffer) = 0;
};

//! Serializes serializable object.
void serialize(const Serializable *serializable, std::vector<uint8_t> *buffer);

//! Serializes data chunk using common schema.
void serialize(const uint8_t *data, size_t size, std::vector<uint8_t> *buffer);

//! Serializes data chunk using common schema.
template <typename T> void serialize(const ConstArrayView1<T> &array, std::vector<uint8_t> *buffer);

//! Deserializes buffer to serializable object.
void deserialize(const std::vector<uint8_t> &buffer, Serializable *serializable);

//! Deserializes buffer to data chunk using common schema.
void deserialize(const std::vector<uint8_t> &buffer, std::vector<uint8_t> *data);

//! Deserializes buffer to data chunk using common schema.
template <typename T> void deserialize(const std::vector<uint8_t> &buffer, Array1<T> *array);

} // namespace  vox

#include "serialization-inl.h"

#endif // INCLUDE_JET_SERIALIZATION_H_
