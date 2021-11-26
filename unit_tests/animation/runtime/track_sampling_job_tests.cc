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

#include "runtime/animation/track_sampling_job.h"

#include "gtest.h"

#include "gtest_math_helper.h"
#include "memory/unique_ptr.h"

#include "offline/animation/raw_track.h"
#include "offline/animation/track_builder.h"

#include "runtime/animation/track.h"

using vox::animation::FloatTrack;
using vox::animation::Float2Track;
using vox::animation::Float3Track;
using vox::animation::Float4Track;
using vox::animation::QuaternionTrack;
using vox::animation::FloatTrackSamplingJob;
using vox::animation::offline::RawFloatTrack;
using vox::animation::offline::TrackBuilder;
using vox::animation::offline::RawTrackInterpolation;

TEST(JobValidity, TrackSamplingJob) {
  // Instantiates a builder objects with default parameters.
  TrackBuilder builder;

  // Building default RawFloatTrack succeeds.
  RawFloatTrack raw_float_track;
  EXPECT_TRUE(raw_float_track.Validate());

  // Builds track
  vox::unique_ptr<FloatTrack> track(builder(raw_float_track));
  ASSERT_TRUE(track);

  {  // Empty/default job
    FloatTrackSamplingJob job;
    EXPECT_FALSE(job.Validate());
    EXPECT_FALSE(job.Run());
  }

  {  // Invalid output
    FloatTrackSamplingJob job;
    job.track = track.get();
    EXPECT_FALSE(job.Validate());
    EXPECT_FALSE(job.Run());
  }

  {  // Invalid track.
    FloatTrackSamplingJob job;
    float result;
    job.result = &result;
    EXPECT_FALSE(job.Validate());
    EXPECT_FALSE(job.Run());
  }

  {  // Valid
    FloatTrackSamplingJob job;
    job.track = track.get();
    float result;
    job.result = &result;
    EXPECT_TRUE(job.Validate());
    EXPECT_TRUE(job.Run());
  }
}

TEST(Default, TrackSamplingJob) {
  FloatTrack default_track;
  FloatTrackSamplingJob job;
  job.track = &default_track;
  float result = 1.f;
  job.result = &result;
  EXPECT_TRUE(job.Validate());
  EXPECT_TRUE(job.Run());
  EXPECT_FLOAT_EQ(result, 0.f);
}

TEST(Bounds, TrackSamplingJob) {
  TrackBuilder builder;
  float result;

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
  vox::unique_ptr<FloatTrack> track(builder(raw_float_track));
  ASSERT_TRUE(track);

  // Samples to verify build output.
  FloatTrackSamplingJob sampling;
  sampling.track = track.get();
  sampling.result = &result;

  sampling.ratio = 0.f - 1e-7f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 0.f);

  sampling.ratio = 0.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 0.f);

  sampling.ratio = .5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 46.f);

  sampling.ratio = 1.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 0.f);

  sampling.ratio = 1.f + 1e-7f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 0.f);

  sampling.ratio = 1.5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 0.f);
}

TEST(Float, TrackSamplingJob) {
  TrackBuilder builder;
  float result;

  vox::animation::offline::RawFloatTrack raw_track;

  const vox::animation::offline::RawFloatTrack::Keyframe key0 = {
      RawTrackInterpolation::kLinear, 0.f, 0.f};
  raw_track.keyframes.push_back(key0);
  const vox::animation::offline::RawFloatTrack::Keyframe key1 = {
      RawTrackInterpolation::kStep, .5f, 4.6f};
  raw_track.keyframes.push_back(key1);
  const vox::animation::offline::RawFloatTrack::Keyframe key2 = {
      RawTrackInterpolation::kLinear, .7f, 9.2f};
  raw_track.keyframes.push_back(key2);
  const vox::animation::offline::RawFloatTrack::Keyframe key3 = {
      RawTrackInterpolation::kLinear, .9f, 0.f};
  raw_track.keyframes.push_back(key3);

  // Builds track
  vox::unique_ptr<FloatTrack> track(builder(raw_track));
  ASSERT_TRUE(track);

  // Samples to verify build output.
  vox::animation::FloatTrackSamplingJob sampling;
  sampling.track = track.get();
  sampling.result = &result;

  sampling.ratio = 0.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 0.f);

  sampling.ratio = .25f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 2.3f);

  sampling.ratio = .5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 4.6f);

  sampling.ratio = .6f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 4.6f);

  sampling.ratio = .7f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 9.2f);

  sampling.ratio = .8f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 4.6f);

  sampling.ratio = .9f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 0.f);

  sampling.ratio = 1.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT_EQ(result, 0.f);
}

TEST(Float2, TrackSamplingJob) {
  TrackBuilder builder;
  vox::math::Float2 result;

  vox::animation::offline::RawFloat2Track raw_track;

  const vox::animation::offline::RawFloat2Track::Keyframe key0 = {
      RawTrackInterpolation::kLinear, 0.f, vox::math::Float2(0.f, 0.f)};
  raw_track.keyframes.push_back(key0);
  const vox::animation::offline::RawFloat2Track::Keyframe key1 = {
      RawTrackInterpolation::kStep, .5f, vox::math::Float2(2.3f, 4.6f)};
  raw_track.keyframes.push_back(key1);
  const vox::animation::offline::RawFloat2Track::Keyframe key2 = {
      RawTrackInterpolation::kLinear, .7f, vox::math::Float2(4.6f, 9.2f)};
  raw_track.keyframes.push_back(key2);
  const vox::animation::offline::RawFloat2Track::Keyframe key3 = {
      RawTrackInterpolation::kLinear, .9f, vox::math::Float2(0.f, 0.f)};
  raw_track.keyframes.push_back(key3);

  // Builds track
  vox::unique_ptr<Float2Track> track(builder(raw_track));
  ASSERT_TRUE(track);

  // Samples to verify build output.
  vox::animation::Float2TrackSamplingJob sampling;
  sampling.track = track.get();
  sampling.result = &result;

  sampling.ratio = 0.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 0.f, 0.f);

  sampling.ratio = .25f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 1.15f, 2.3f);

  sampling.ratio = .5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 2.3f, 4.6f);

  sampling.ratio = .6f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 2.3f, 4.6f);

  sampling.ratio = .7f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 4.6f, 9.2f);

  sampling.ratio = .8f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 2.3f, 4.6f);

  sampling.ratio = .9f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 0.f, 0.f);

  sampling.ratio = 1.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT2_EQ(result, 0.f, 0.f);
}

TEST(Float3, TrackSamplingJob) {
  TrackBuilder builder;
  vox::math::Float3 result;

  vox::animation::offline::RawFloat3Track raw_track;

  const vox::animation::offline::RawFloat3Track::Keyframe key0 = {
      RawTrackInterpolation::kLinear, 0.f, vox::math::Float3(0.f, 0.f, 0.f)};
  raw_track.keyframes.push_back(key0);
  const vox::animation::offline::RawFloat3Track::Keyframe key1 = {
      RawTrackInterpolation::kStep, .5f, vox::math::Float3(0.f, 2.3f, 4.6f)};
  raw_track.keyframes.push_back(key1);
  const vox::animation::offline::RawFloat3Track::Keyframe key2 = {
      RawTrackInterpolation::kLinear, .7f, vox::math::Float3(0.f, 4.6f, 9.2f)};
  raw_track.keyframes.push_back(key2);
  const vox::animation::offline::RawFloat3Track::Keyframe key3 = {
      RawTrackInterpolation::kLinear, .9f, vox::math::Float3(0.f, 0.f, 0.f)};
  raw_track.keyframes.push_back(key3);

  // Builds track
  vox::unique_ptr<Float3Track> track(builder(raw_track));
  ASSERT_TRUE(track);

  // Samples to verify build output.
  vox::animation::Float3TrackSamplingJob sampling;
  sampling.track = track.get();
  sampling.result = &result;

  sampling.ratio = 0.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 0.f, 0.f, 0.f);

  sampling.ratio = .25f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 0.f, 1.15f, 2.3f);

  sampling.ratio = .5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 0.f, 2.3f, 4.6f);

  sampling.ratio = .6f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 0.f, 2.3f, 4.6f);

  sampling.ratio = .7f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 0.f, 4.6f, 9.2f);

  sampling.ratio = .8f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 0.f, 2.3f, 4.6f);

  sampling.ratio = .9f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 0.f, 0.f, 0.f);

  sampling.ratio = 1.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT3_EQ(result, 0.f, 0.f, 0.f);
}

TEST(Float4, TrackSamplingJob) {
  TrackBuilder builder;
  vox::math::Float4 result;

  vox::animation::offline::RawFloat4Track raw_track;

  const vox::animation::offline::RawFloat4Track::Keyframe key0 = {
      RawTrackInterpolation::kLinear, 0.f,
      vox::math::Float4(0.f, 0.f, 0.f, 0.f)};
  raw_track.keyframes.push_back(key0);
  const vox::animation::offline::RawFloat4Track::Keyframe key1 = {
      RawTrackInterpolation::kStep, .5f,
      vox::math::Float4(0.f, 2.3f, 0.f, 4.6f)};
  raw_track.keyframes.push_back(key1);
  const vox::animation::offline::RawFloat4Track::Keyframe key2 = {
      RawTrackInterpolation::kLinear, .7f,
      vox::math::Float4(0.f, 4.6f, 0.f, 9.2f)};
  raw_track.keyframes.push_back(key2);
  const vox::animation::offline::RawFloat4Track::Keyframe key3 = {
      RawTrackInterpolation::kLinear, .9f,
      vox::math::Float4(0.f, 0.f, 0.f, 0.f)};
  raw_track.keyframes.push_back(key3);

  // Builds track
  vox::unique_ptr<Float4Track> track(builder(raw_track));
  ASSERT_TRUE(track);

  // Samples to verify build output.
  vox::animation::Float4TrackSamplingJob sampling;
  sampling.track = track.get();
  sampling.result = &result;

  sampling.ratio = 0.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 0.f, 0.f, 0.f, 0.f);

  sampling.ratio = .25f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 0.f, 1.15f, 0.f, 2.3f);

  sampling.ratio = .5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 0.f, 2.3f, 0.f, 4.6f);

  sampling.ratio = .6f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 0.f, 2.3f, 0.f, 4.6f);

  sampling.ratio = .7f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 0.f, 4.6f, 0.f, 9.2f);

  sampling.ratio = .8f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 0.f, 2.3f, 0.f, 4.6f);

  sampling.ratio = .9f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 0.f, 0.f, 0.f, 0.f);

  sampling.ratio = 1.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_FLOAT4_EQ(result, 0.f, 0.f, 0.f, 0.f);
}

TEST(Quaternion, TrackSamplingJob) {
  TrackBuilder builder;
  vox::math::Quaternion result;

  vox::animation::offline::RawQuaternionTrack raw_track;

  const vox::animation::offline::RawQuaternionTrack::Keyframe key0 = {
      RawTrackInterpolation::kLinear, 0.f,
      vox::math::Quaternion(.70710677f, 0.f, 0.f, .70710677f)};
  raw_track.keyframes.push_back(key0);
  const vox::animation::offline::RawQuaternionTrack::Keyframe key1 = {
      RawTrackInterpolation::kStep, .5f,
      vox::math::Quaternion(0.f, .70710677f, 0.f, .70710677f)};
  raw_track.keyframes.push_back(key1);
  const vox::animation::offline::RawQuaternionTrack::Keyframe key2 = {
      RawTrackInterpolation::kLinear, .7f,
      vox::math::Quaternion(.70710677f, 0.f, 0.f, .70710677f)};
  raw_track.keyframes.push_back(key2);
  const vox::animation::offline::RawQuaternionTrack::Keyframe key3 = {
      RawTrackInterpolation::kLinear, .9f, vox::math::Quaternion::identity()};
  raw_track.keyframes.push_back(key3);

  // Builds track
  vox::unique_ptr<QuaternionTrack> track(builder(raw_track));
  ASSERT_TRUE(track);
  // Samples to verify build output.
  vox::animation::QuaternionTrackSamplingJob sampling;
  sampling.track = track.get();
  sampling.result = &result;

  sampling.ratio = 0.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, .70710677f, 0.f, 0.f, .70710677f);

  sampling.ratio = .1f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, .61721331f, .15430345f, 0.f, .77151674f);

  sampling.ratio = .4999999f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, 0.f, .70710677f, 0.f, .70710677f);

  sampling.ratio = .5f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, 0.f, .70710677f, 0.f, .70710677f);

  sampling.ratio = .6f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, 0.f, .70710677f, 0.f, .70710677f);

  sampling.ratio = .7f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, .70710677f, 0.f, 0.f, .70710677f);

  sampling.ratio = .8f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, .38268333f, 0.f, 0.f, .92387962f);

  sampling.ratio = .9f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, 0.f, 0.f, 0.f, 1.f);

  sampling.ratio = 1.f;
  ASSERT_TRUE(sampling.Run());
  EXPECT_QUATERNION_EQ(result, 0.f, 0.f, 0.f, 1.f);
}
