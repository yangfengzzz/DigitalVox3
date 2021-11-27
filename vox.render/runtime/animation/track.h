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

#ifndef VOX_VOX_ANIMATION_RUNTIME_TRACK_H_
#define VOX_VOX_ANIMATION_RUNTIME_TRACK_H_

#include "io/archive_traits.h"
#include "platform.h"
#include "span.h"

#include "maths/quaternion.h"
#include "maths/vec_float.h"

namespace vox {
namespace animation {

// Forward declares the TrackBuilder, used to instantiate a Track.
namespace offline {
class TrackBuilder;
}

namespace internal {
// Runtime user-channel track internal implementation.
// The runtime track data structure exists for 1 to 4 float types (FloatTrack,
// ..., Float4Track) and quaternions (QuaternionTrack). See RawTrack for more
// details on track content. The runtime track data structure is optimized for
// the processing of vox::animation::TrackSamplingJob and
// vox::animation::TrackTriggeringJob. Keyframe ratios, values and interpolation
// mode are all store as separate buffers in order to access the cache
// coherently. Ratios are usually accessed/read alone from the jobs that all
// start by looking up the keyframes to interpolate indeed.
template <typename _ValueType>
class Track {
 public:
  typedef _ValueType ValueType;

  Track();
  ~Track();

  // Keyframe accessors.
  span<const float> ratios() const { return ratios_; }
  span<const _ValueType> values() const { return values_; }
  span<const uint8_t> steps() const { return steps_; }

  // Get the estimated track's size in bytes.
  size_t size() const;

  // Get track name.
  const char* name() const { return name_ ? name_ : ""; }

  // Serialization functions.
  // Should not be called directly but through io::Archive << and >> operators.
  void Save(vox::io::OArchive& _archive) const;
  void Load(vox::io::IArchive& _archive, uint32_t _version);

 private:
  // Disables copy and assignation.
  Track(Track const&);
  void operator=(Track const&);

  // TrackBuilder class is allowed to allocate a Track.
  friend class offline::TrackBuilder;

  // Internal destruction function.
  void Allocate(size_t _keys_count, size_t _name_len);
  void Deallocate();

  // Keyframe ratios (0 is the beginning of the track, 1 is the end).
  span<float> ratios_;

  // Keyframe values.
  span<_ValueType> values_;

  // Keyframe modes (1 bit per key): 1 for step, 0 for linear.
  span<uint8_t> steps_;

  // Track name.
  char* name_;
};

// Definition of operations policies per track value type.
template <typename _ValueType>
struct TrackPolicy {
  inline static _ValueType Lerp(const _ValueType& _a, const _ValueType& _b,
                                float _alpha) {
    return math::Lerp(_a, _b, _alpha);
  }
  inline static float Distance(const _ValueType& _a, const _ValueType& _b) {
    return math::Length(_a - _b);
  }
  inline static _ValueType identity() { return _ValueType(0.f); }
};

// Specialization for float policy.
template <>
inline float TrackPolicy<float>::Distance(const float& _a, const float& _b) {
  return std::abs(_a - _b);
}

// Specialization for quaternions policy.
template <>
inline math::Quaternion TrackPolicy<math::Quaternion>::Lerp(
    const math::Quaternion& _a, const math::Quaternion& _b, float _alpha) {
  // Uses NLerp to favor speed. This same function is used when optimizing the
  // curve (key frame reduction), so "constant speed" interpolation can still be
  // approximated with a lower tolerance value if it matters.
  return math::NLerp(_a, _b, _alpha);
}
template <>
inline float TrackPolicy<math::Quaternion>::Distance(
    const math::Quaternion& _a, const math::Quaternion& _b) {
  const float cos_half_angle =
      _a.x * _b.x + _a.y * _b.y + _a.z * _b.z + _a.w * _b.w;
  // Return value is 1 - half cosine, so the closer the quaternions, the closer
  // to 0.
  return 1.f - math::Min(1.f, std::abs(cos_half_angle));
}
template <>
inline math::Quaternion TrackPolicy<math::Quaternion>::identity() {
  return math::Quaternion::identity();
}
}  // namespace internal

// Runtime track data structure instantiation.
class FloatTrack : public internal::Track<float> {};
class Float2Track : public internal::Track<math::Float2> {};
class Float3Track : public internal::Track<math::Float3> {};
class Float4Track : public internal::Track<math::Float4> {};
class QuaternionTrack : public internal::Track<math::Quaternion> {};

}  // namespace animation
namespace io {
VOX_IO_TYPE_VERSION(1, animation::FloatTrack)
VOX_IO_TYPE_TAG("vox-float_track", animation::FloatTrack)
VOX_IO_TYPE_VERSION(1, animation::Float2Track)
VOX_IO_TYPE_TAG("vox-float2_track", animation::Float2Track)
VOX_IO_TYPE_VERSION(1, animation::Float3Track)
VOX_IO_TYPE_TAG("vox-float3_track", animation::Float3Track)
VOX_IO_TYPE_VERSION(1, animation::Float4Track)
VOX_IO_TYPE_TAG("vox-float4_track", animation::Float4Track)
VOX_IO_TYPE_VERSION(1, animation::QuaternionTrack)
VOX_IO_TYPE_TAG("vox-quat_track", animation::QuaternionTrack)
}  // namespace io
}  // namespace vox
#endif  // VOX_VOX_ANIMATION_RUNTIME_TRACK_H_