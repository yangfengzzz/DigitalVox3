// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_CONSTANTS_H_
#define INCLUDE_JET_CONSTANTS_H_

#include "macros.h"
#include <cmath>
#include <limits>

namespace vox {

// MARK: Zero

//! Zero size_t.
constexpr size_t kZeroSize = 0;

//! Zero ssize_t.
constexpr ssize_t kZeroSSize = 0;

//! Zero for type T.
template <typename T> constexpr T zero() { return 0; }

//! Zero for float.
template <> constexpr float zero<float>() { return 0.f; }

//! Zero for double.
template <> constexpr double zero<double>() { return 0.0; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: 1/3

//! 1/3 float
constexpr float kOneThirdF = 1.f / 3.f;

//! 1/3 double
constexpr double kOneThirdD = 1.0 / 3.0;

//! 1/3 for type T
template <typename T> constexpr T oneThird() { return static_cast<T>(kOneThirdD); }

//! 1/3 for float
template <> constexpr float oneThird<float>() { return kOneThirdF; }

//! 1/3 for double
template <> constexpr double oneThird<double>() { return kOneThirdD; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: 1/2

//! 1/2 float
constexpr float kHalfF = 0.5f;

//! 1/2 double
constexpr double kHalfD = 0.5;

//! 1/2 for type T
template <typename T> constexpr T half() { return static_cast<T>(kHalfD); }

//! 1/2 for float
template <> constexpr float half<float>() { return kHalfF; }

//! 1/2 for double
template <> constexpr double half<double>() { return kHalfD; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: One

//! One size_t.
constexpr size_t kOneSize = 1;

//! One ssize_t.
constexpr ssize_t kOneSSize = 1;

//! One for type T.
template <typename T> constexpr T one() { return 1; }

//! One for float.
template <> constexpr float one<float>() { return 1.f; }

//! One for double.
template <> constexpr double one<double>() { return 1.0; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: 1.5

//! 1.5 for type T.
template <typename T> constexpr T oneAndHalf() { return static_cast<T>(1.5); }

//! 1.5 for float.
template <> constexpr float oneAndHalf<float>() { return 1.5f; }

//! 1.5 for double.
template <> constexpr double oneAndHalf<double>() { return 1.5; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: Two

//! Two size_t.
constexpr size_t kTwoSize = 2;

//! Two ssize_t.
constexpr ssize_t kTwoSSize = 2;

//! Two for type T.
template <typename T> constexpr T two() { return 2; }

//! Two for float.
template <> constexpr float two<float>() { return 2.f; }

//! Two for double.
template <> constexpr double two<double>() { return 2.0; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: Epsilon

//! Float-type epsilon.
constexpr float kEpsilonF = std::numeric_limits<float>::epsilon();

//! Double-type epsilon.
constexpr double kEpsilonD = std::numeric_limits<double>::epsilon();

//----------------------------------------------------------------------------------------------------------------------
// MARK: Max

//! Max size_t.
constexpr size_t kMaxSize = std::numeric_limits<size_t>::max();

//! Max ssize_t.
constexpr ssize_t kMaxSSize = std::numeric_limits<ssize_t>::max();

//! Max float.
constexpr float kMaxF = std::numeric_limits<float>::max();

//! Max double.
constexpr double kMaxD = std::numeric_limits<double>::max();

//----------------------------------------------------------------------------------------------------------------------
// MARK: Pi

//! Float-type pi.
constexpr float kPiF = 3.14159265358979323846264338327950288f;

//! Double-type pi.
constexpr double kPiD = 3.14159265358979323846264338327950288;

//! Pi for type T.
template <typename T> constexpr T pi() { return static_cast<T>(kPiD); }

//! Pi for float.
template <> constexpr float pi<float>() { return kPiF; }

//! Pi for double.
template <> constexpr double pi<double>() { return kPiD; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: Pi/2

//! Float-type pi/2.
constexpr float kHalfPiF = 1.57079632679489661923132169163975144f;

//! Double-type pi/2.
constexpr double kHalfPiD = 1.57079632679489661923132169163975144;

//! Pi/2 for type T.
template <typename T> constexpr T halfPi() { return static_cast<T>(kHalfPiD); }

//! Pi/2 for float.
template <> constexpr float halfPi<float>() { return kHalfPiF; }

//! Pi/2 for double.
template <> constexpr double halfPi<double>() { return kHalfPiD; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: Pi/4

//! Float-type pi/4.
constexpr float kQuarterPiF = 0.785398163397448309615660845819875721f;

//! Double-type pi/4.
constexpr double kQuarterPiD = 0.785398163397448309615660845819875721;

//! Pi/4 for type T.
template <typename T> constexpr T quarterPi() { return static_cast<T>(kQuarterPiD); }

//! Pi/2 for float.
template <> constexpr float quarterPi<float>() { return kQuarterPiF; }

//! Pi/2 for double.
template <> constexpr double quarterPi<double>() { return kQuarterPiD; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: 2*Pi

//! Float-type 2*pi.
constexpr float kTwoPiF = static_cast<float>(2.0 * kPiD);

//! Double-type 2*pi.
constexpr double kTwoPiD = 2.0 * kPiD;

//! 2*pi for type T.
template <typename T> constexpr T twoPi() { return static_cast<T>(kTwoPiD); }

//! 2*pi for float.
template <> constexpr float twoPi<float>() { return kTwoPiF; }

//! 2*pi for double.
template <> constexpr double twoPi<double>() { return kTwoPiD; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: 4*Pi

//! Float-type 4*pi.
constexpr float kFourPiF = static_cast<float>(4.0 * kPiD);

//! Double-type 4*pi.
constexpr double kFourPiD = 4.0 * kPiD;

//! 4*pi for type T.
template <typename T> constexpr T fourPi() { return static_cast<T>(kFourPiD); }

//! 4*pi for float.
template <> constexpr float fourPi<float>() { return kFourPiF; }

//! 4*pi for double.
template <> constexpr double fourPi<double>() { return kFourPiD; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: 1/Pi

//! Float-type 1/pi.
constexpr float kInvPiF = static_cast<float>(1.0 / kPiD);

//! Double-type 1/pi.
constexpr double kInvPiD = 1.0 / kPiD;

//! 1/pi for type T.
template <typename T> constexpr T invPi() { return static_cast<T>(kInvPiD); }

//! 1/pi for float.
template <> constexpr float invPi<float>() { return kInvPiF; }

//! 1/pi for double.
template <> constexpr double invPi<double>() { return kInvPiD; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: 1/2*Pi

//! Float-type 1/2*pi.
constexpr float kInvTwoPiF = static_cast<float>(0.5 / kPiD);

//! Double-type 1/2*pi.
constexpr double kInvTwoPiD = 0.5 / kPiD;

//! 1/2*pi for type T.
template <typename T> constexpr T invTwoPi() { return static_cast<T>(kInvTwoPiD); }

//! 1/2*pi for float.
template <> constexpr float invTwoPi<float>() { return kInvTwoPiF; }

//! 1/2*pi for double.
template <> constexpr double invTwoPi<double>() { return kInvTwoPiD; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: 1/4*Pi

//! Float-type 1/4*pi.
constexpr float kInvFourPiF = static_cast<float>(0.25 / kPiD);

//! Double-type 1/4*pi.
constexpr double kInvFourPiD = 0.25 / kPiD;

//! 1/4*pi for type T.
template <typename T> constexpr T invFourPi() { return static_cast<T>(kInvFourPiD); }

//! 1/4*pi for float.
template <> constexpr float invFourPi<float>() { return kInvFourPiF; }

//! 1/4*pi for double.
template <> constexpr double invFourPi<double>() { return kInvFourPiD; }

//----------------------------------------------------------------------------------------------------------------------
// MARK: Physics

//! Gravity.
constexpr float kGravityF = -9.8f;
constexpr double kGravityD = -9.8;

//! Water density.
constexpr float kWaterDensityF = 1000.0f;
constexpr double kWaterDensityD = 1000.0;

//! Speed of sound in water at 20 degrees Celsius.
constexpr float kSpeedOfSoundInWaterF = 1482.0f;
constexpr double kSpeedOfSoundInWaterD = 1482.0;

// MARK: Common enums

//! No direction.
constexpr int kDirectionNone = 0;

//! Left direction.
constexpr int kDirectionLeft = 1 << 0;

//! Right direction.
constexpr int kDirectionRight = 1 << 1;

//! Down direction.
constexpr int kDirectionDown = 1 << 2;

//! Up direction.
constexpr int kDirectionUp = 1 << 3;

//! Back direction.
constexpr int kDirectionBack = 1 << 4;

//! Front direction.
constexpr int kDirectionFront = 1 << 5;

//! All direction.
constexpr int kDirectionAll =
    kDirectionLeft | kDirectionRight | kDirectionDown | kDirectionUp | kDirectionBack | kDirectionFront;

} // namespace  vox

#endif // INCLUDE_JET_CONSTANTS_H_
