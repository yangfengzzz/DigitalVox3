// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef SRC_JET_PHYSICS_HELPERS_H_
#define SRC_JET_PHYSICS_HELPERS_H_

#include "matrix.h"

#include <algorithm>

namespace vox {
namespace geometry {

inline Vector2D computeDragForce(double dragCoefficient, double radius, const Vector2D &velocity) {
  // Stokes's drag force assuming our Reynolds number is very low.
  // http://en.wikipedia.org/wiki/Drag_(physics)#Very_low_Reynolds_numbers:_Stokes.27_drag
  return -6.0 * kPiD * dragCoefficient * radius * velocity;
}

inline Vector3D computeDragForce(double dragCoefficient, double radius, const Vector3D &velocity) {
  // Stokes's drag force assuming our Reynolds number is very low.
  // http://en.wikipedia.org/wiki/Drag_(physics)#Very_low_Reynolds_numbers:_Stokes.27_drag
  return -6.0 * kPiD * dragCoefficient * radius * velocity;
}

template <size_t N>
inline Vector<double, N> projectAndApplyFriction(const Vector<double, N> &vel, const Vector<double, N> &normal,
                                                 double frictionCoefficient) {
  Vector<double, N> velt = vel.projected(normal);
  if (velt.lengthSquared() > 0) {
    double veln = std::max(-vel.dot(normal), 0.0);
    velt *= std::max(1.0 - frictionCoefficient * veln / velt.length(), 0.0);
  }

  return velt;
}

inline double computePressureFromEos(double density, double targetDensity, double eosScale, double eosExponent,
                                     double negativePressureScale) {
  // Equation of state
  // (http://www.ifi.uzh.ch/vmml/publications/pcisph/pcisph.pdf)
  double p = eosScale / eosExponent * (std::pow((density / targetDensity), eosExponent) - 1.0);

  // Negative pressure scaling
  if (p < 0) {
    p *= negativePressureScale;
  }

  return p;
}

} // namespace vox
} // namespace geometry

#endif // SRC_JET_PHYSICS_HELPERS_H_
