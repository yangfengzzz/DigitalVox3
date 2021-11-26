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

#include "runtime/animation/track.h"

#include "gtest.h"
#include "gtest_math_helper.h"

#include "io/archive.h"
#include "io/stream.h"
#include "memory/unique_ptr.h"

#include "runtime/animation/track_sampling_job.h"

#include "offline/animation/raw_track.h"
#include "offline/animation/track_builder.h"

using vox::animation::FloatTrack;
using vox::animation::FloatTrackSamplingJob;
using vox::animation::Float2Track;
using vox::animation::Float2TrackSamplingJob;
using vox::animation::Float3Track;
using vox::animation::Float3TrackSamplingJob;
using vox::animation::Float4Track;
using vox::animation::Float4TrackSamplingJob;
using vox::animation::QuaternionTrack;
using vox::animation::QuaternionTrackSamplingJob;
using vox::animation::offline::RawFloatTrack;
using vox::animation::offline::RawFloat2Track;
using vox::animation::offline::RawFloat3Track;
using vox::animation::offline::RawFloat4Track;
using vox::animation::offline::RawQuaternionTrack;
using vox::animation::offline::RawTrackInterpolation;
using vox::animation::offline::TrackBuilder;

TEST(Empty, TrackSerialize) {
  vox::io::MemoryStream stream;

  // Streams out.
  vox::io::OArchive o(&stream, vox::GetNativeEndianness());

  FloatTrack o_track;
  o << o_track;

  // Streams in.
  stream.Seek(0, vox::io::Stream::kSet);
  vox::io::IArchive i(&stream);

  FloatTrack i_track;
  i >> i_track;

  EXPECT_EQ(o_track.size(), i_track.size());
}

TEST(Name, TrackSerialize) {
  vox::io::MemoryStream stream;

  // Instantiates a builder objects with default parameters.
  TrackBuilder builder;

  {  // No name
    RawFloatTrack raw_float_track;

    vox::unique_ptr<FloatTrack> o_track(builder(raw_float_track));
    ASSERT_TRUE(o_track);

    // Streams out.
    {
      stream.Seek(0, vox::io::Stream::kSet);
      vox::io::OArchive o(&stream, vox::GetNativeEndianness());
      o << *o_track;
    }

    // Streams in.
    stream.Seek(0, vox::io::Stream::kSet);
    vox::io::IArchive i(&stream);

    FloatTrack i_track;
    i >> i_track;

    EXPECT_STREQ(o_track->name(), i_track.name());
  }

  {  // A name
    RawFloatTrack raw_float_track;
    raw_float_track.name = "test name";

    vox::unique_ptr<FloatTrack> o_track(builder(raw_float_track));
    ASSERT_TRUE(o_track);

    // Streams out.
    {
      stream.Seek(0, vox::io::Stream::kSet);
      vox::io::OArchive o(&stream, vox::GetNativeEndianness());
      o << *o_track;
    }

    // Streams in.
    stream.Seek(0, vox::io::Stream::kSet);
    vox::io::IArchive i(&stream);

    FloatTrack i_track;
    i >> i_track;

    EXPECT_STREQ(o_track->name(), i_track.name());
  }
}

TEST(FilledFloat, TrackSerialize) {
  // Builds a valid animation.
  vox::unique_ptr<FloatTrack> o_track;
  {
    TrackBuilder builder;
    RawFloatTrack raw_float_track;

    const RawFloatTrack::Keyframe key0 = {RawTrackInterpolation::kLinear, 0.f,
                                          0.f};
    raw_float_track.keyframes.push_back(key0);
    const RawFloatTrack::Keyframe key1 = {RawTrackInterpolation::kStep, .5f,
                                          46.f};
    raw_float_track.keyframes.push_back(key1);
    const RawFloatTrack::Keyframe key2 = {RawTrackInterpolation::kLinear, .7f,
                                          0.f};
    raw_float_track.keyframes.push_back(key2);

    // Builds track
    o_track = builder(raw_float_track);
    ASSERT_TRUE(o_track);
  }

  for (int e = 0; e < 2; ++e) {
    vox::Endianness endianess = e == 0 ? vox::kBigEndian : vox::kLittleEndian;
    vox::io::MemoryStream stream;

    // Streams out.
    vox::io::OArchive o(&stream, endianess);
    o << *o_track;

    // Streams in.
    stream.Seek(0, vox::io::Stream::kSet);
    vox::io::IArchive i(&stream);

    FloatTrack i_track;
    i >> i_track;

    EXPECT_EQ(o_track->size(), i_track.size());

    // Samples and compares the two animations
    FloatTrackSamplingJob sampling;
    sampling.track = &i_track;
    float result;
    sampling.result = &result;

    sampling.ratio = 0.f;
    ASSERT_TRUE(sampling.Run());
    EXPECT_FLOAT_EQ(result, 0.f);

    sampling.ratio = .5f;
    ASSERT_TRUE(sampling.Run());
    EXPECT_FLOAT_EQ(result, 46.f);

    sampling.ratio = 1.f;
    ASSERT_TRUE(sampling.Run());
    EXPECT_FLOAT_EQ(result, 0.f);
  }
}

TEST(FilledFloat2, TrackSerialize) {
  TrackBuilder builder;
  RawFloat2Track raw_float2_track;

  const RawFloat2Track::Keyframe key0 = {RawTrackInterpolation::kLinear, 0.f,
                                         vox::math::Float2(0.f, 26.f)};
  raw_float2_track.keyframes.push_back(key0);
  const RawFloat2Track::Keyframe key1 = {RawTrackInterpolation::kStep, .5f,
                                         vox::math::Float2(46.f, 0.f)};
  raw_float2_track.keyframes.push_back(key1);
  const RawFloat2Track::Keyframe key2 = {RawTrackInterpolation::kLinear, .7f,
                                         vox::math::Float2(0.f, 5.f)};
  raw_float2_track.keyframes.push_back(key2);

  // Builds track
  vox::unique_ptr<Float2Track> o_track(builder(raw_float2_track));
  ASSERT_TRUE(o_track);

  vox::io::MemoryStream stream;

  // Streams out.
  vox::io::OArchive o(&stream);
  o << *o_track;

  // Streams in.
  stream.Seek(0, vox::io::Stream::kSet);
  vox::io::IArchive i(&stream);

  Float2Track i_track;
  i >> i_track;

  EXPECT_EQ(o_track->size(), i_track.size());

  // Samples and compares the two animations
  Float2TrackSamplingJob sampling;
  sampling.track = &i_track;
  vox::math::Float2 result;
  sampling.result = &result;

  sampling.ratio = 0.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 0.f, 26.f);

  sampling.ratio = .5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 46.f, 0.f);

  sampling.ratio = 1.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 0.f, 5.f);
}

TEST(FilledFloat3, TrackSerialize) {
  TrackBuilder builder;
  RawFloat3Track raw_float3_track;

  const RawFloat3Track::Keyframe key0 = {RawTrackInterpolation::kLinear, 0.f,
                                         vox::math::Float3(0.f, 26.f, 93.f)};
  raw_float3_track.keyframes.push_back(key0);
  const RawFloat3Track::Keyframe key1 = {RawTrackInterpolation::kStep, .5f,
                                         vox::math::Float3(46.f, 0.f, 25.f)};
  raw_float3_track.keyframes.push_back(key1);
  const RawFloat3Track::Keyframe key2 = {RawTrackInterpolation::kLinear, .7f,
                                         vox::math::Float3(0.f, 5.f, 0.f)};
  raw_float3_track.keyframes.push_back(key2);

  // Builds track
  vox::unique_ptr<Float3Track> o_track(builder(raw_float3_track));
  ASSERT_TRUE(o_track);

  vox::io::MemoryStream stream;

  // Streams out.
  vox::io::OArchive o(&stream);
  o << *o_track;

  // Streams in.
  stream.Seek(0, vox::io::Stream::kSet);
  vox::io::IArchive i(&stream);

  Float3Track i_track;
  i >> i_track;

  EXPECT_EQ(o_track->size(), i_track.size());

  // Samples and compares the two animations
  Float3TrackSamplingJob sampling;
  sampling.track = &i_track;
  vox::math::Float3 result;
  sampling.result = &result;

  sampling.ratio = 0.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 0.f, 26.f, 93.f);

  sampling.ratio = .5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 46.f, 0.f, 25.f);

  sampling.ratio = 1.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 0.f, 5.f, 0.f);
}

TEST(FilledFloat4, TrackSerialize) {
  TrackBuilder builder;
  RawFloat4Track raw_float4_track;

  const RawFloat4Track::Keyframe key0 = {
      RawTrackInterpolation::kLinear, 0.f,
      vox::math::Float4(0.f, 26.f, 93.f, 5.f)};
  raw_float4_track.keyframes.push_back(key0);
  const RawFloat4Track::Keyframe key1 = {
      RawTrackInterpolation::kStep, .5f,
      vox::math::Float4(46.f, 0.f, 25.f, 25.f)};
  raw_float4_track.keyframes.push_back(key1);
  const RawFloat4Track::Keyframe key2 = {RawTrackInterpolation::kLinear, .7f,
                                         vox::math::Float4(0.f, 5.f, 0.f, 0.f)};
  raw_float4_track.keyframes.push_back(key2);

  // Builds track
  vox::unique_ptr<Float4Track> o_track(builder(raw_float4_track));
  ASSERT_TRUE(o_track);

  vox::io::MemoryStream stream;

  // Streams out.
  vox::io::OArchive o(&stream);
  o << *o_track;

  // Streams in.
  stream.Seek(0, vox::io::Stream::kSet);
  vox::io::IArchive i(&stream);

  Float4Track i_track;
  i >> i_track;

  EXPECT_EQ(o_track->size(), i_track.size());

  // Samples and compares the two animations
  Float4TrackSamplingJob sampling;
  sampling.track = &i_track;
  vox::math::Float4 result;
  sampling.result = &result;

  sampling.ratio = 0.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 0.f, 26.f, 93.f, 5.f);

  sampling.ratio = .5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 46.f, 0.f, 25.f, 25.f);

  sampling.ratio = 1.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 0.f, 5.f, 0.f, 0.f);
}

TEST(FilledQuaternion, TrackSerialize) {
  TrackBuilder builder;
  RawQuaternionTrack raw_quat_track;

  const RawQuaternionTrack::Keyframe key0 = {
      RawTrackInterpolation::kLinear, 0.f,
      vox::math::Quaternion(0.f, .70710677f, 0.f, .70710677f)};
  raw_quat_track.keyframes.push_back(key0);
  const RawQuaternionTrack::Keyframe key1 = {
      RawTrackInterpolation::kStep, .5f,
      vox::math::Quaternion(.61721331f, .15430345f, 0.f, .77151674f)};
  raw_quat_track.keyframes.push_back(key1);
  const RawQuaternionTrack::Keyframe key2 = {
      RawTrackInterpolation::kLinear, .7f,
      vox::math::Quaternion(1.f, 0.f, 0.f, 0.f)};
  raw_quat_track.keyframes.push_back(key2);

  // Builds track
  vox::unique_ptr<QuaternionTrack> o_track(builder(raw_quat_track));
  ASSERT_TRUE(o_track);

  vox::io::MemoryStream stream;

  // Streams out.
  vox::io::OArchive o(&stream);
  o << *o_track;

  // Streams in.
  stream.Seek(0, vox::io::Stream::kSet);
  vox::io::IArchive i(&stream);

  QuaternionTrack i_track;
  i >> i_track;

  EXPECT_EQ(o_track->size(), i_track.size());

  // Samples and compares the two animations
  QuaternionTrackSamplingJob sampling;
  sampling.track = &i_track;
  vox::math::Quaternion result;
  sampling.result = &result;

  sampling.ratio = 0.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, 0.f, .70710677f, 0.f, .70710677f);

  sampling.ratio = .5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, .61721331f, .15430345f, 0.f, .77151674f);

  sampling.ratio = 1.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, 1.f, 0.f, 0.f, 0.f);
}

TEST(AlreadyInitialized, TrackSerialize) {
  vox::io::MemoryStream stream;

  {
    vox::io::OArchive o(&stream);

    TrackBuilder builder;
    RawFloatTrack raw_float_track;

    const RawFloatTrack::Keyframe key0 = {RawTrackInterpolation::kLinear, 0.f,
                                          0.f};
    raw_float_track.keyframes.push_back(key0);
    const RawFloatTrack::Keyframe key1 = {RawTrackInterpolation::kStep, .5f,
                                          46.f};
    raw_float_track.keyframes.push_back(key1);
    const RawFloatTrack::Keyframe key2 = {RawTrackInterpolation::kLinear, .7f,
                                          0.f};
    raw_float_track.keyframes.push_back(key2);

    // Builds track
    vox::unique_ptr<FloatTrack> o_track(builder(raw_float_track));
    ASSERT_TRUE(o_track);

    o << *o_track;

    // Builds 2nd track
    const RawFloatTrack::Keyframe key3 = {RawTrackInterpolation::kStep, .9f,
                                          46.f};
    raw_float_track.keyframes.push_back(key3);

    o_track = builder(raw_float_track);
    ASSERT_TRUE(o_track);
    o << *o_track;
  }

  {
    // Streams in.
    stream.Seek(0, vox::io::Stream::kSet);
    vox::io::IArchive i(&stream);

    // Reads and check the first animation.
    FloatTrack i_track;
    i >> i_track;
    const size_t size = i_track.size();

    // Reuse the animation a second ratio.
    i >> i_track;
    ASSERT_TRUE(i_track.size() > size);
  }
}
