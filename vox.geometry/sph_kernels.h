// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.
//
// Adopted from the sample code of:
// Bart Adams and Martin Wicke,
// "Meshless Approximation Methods and Applications in Physics Based Modeling
// and Animation", Eurographics 2009 Tutorial

#ifndef INCLUDE_JET_SPH_KERNELS_H_
#define INCLUDE_JET_SPH_KERNELS_H_

#include "constants.h"
#include "matrix.h"

namespace vox {
namespace geometry {

//!
//! \brief Standard N-D SPH kernel function object.
//!
//! \see Müller, Matthias, David Charypar, and Markus Gross.
//!     "Particle-based fluid simulation for interactive applications."
//!     Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
//!     animation. Eurographics Association, 2003.
//!
template <size_t N> struct SphStdKernel {};

template <> struct SphStdKernel<2> {
  //! Kernel radius.
  double h;

  //! Square of the kernel radius.
  double h2;

  //! Cubic of the kernel radius.
  double h3;

  //! Fourth-power of the kernel radius.
  double h4;

  //! Constructs a kernel object with zero radius.
  SphStdKernel();

  //! Constructs a kernel object with given radius.
  explicit SphStdKernel(double kernelRadius);

  //! Copy constructor
  SphStdKernel(const SphStdKernel &other) = default;

  //! Returns kernel function value at given distance.
  double operator()(double distance) const;

  //! Returns the first derivative at given distance.
  double firstDerivative(double distance) const;

  //! Returns the gradient at a point.
  Vector2D gradient(const Vector2D &point) const;

  //! Returns the gradient at a point defined by distance and direction.
  Vector2D gradient(double distance, const Vector2D &direction) const;

  //! Returns the second derivative at given distance.
  double secondDerivative(double distance) const;
};

template <> struct SphStdKernel<3> {
  //! Kernel radius.
  double h;

  //! Square of the kernel radius.
  double h2;

  //! Cubic of the kernel radius.
  double h3;

  //! Fifth-power of the kernel radius.
  double h5;

  //! Constructs a kernel object with zero radius.
  SphStdKernel();

  //! Constructs a kernel object with given radius.
  explicit SphStdKernel(double kernelRadius);

  //! Copy constructor
  SphStdKernel(const SphStdKernel &other) = default;

  //! Returns kernel function value at given distance.
  double operator()(double distance) const;

  //! Returns the first derivative at given distance.
  double firstDerivative(double distance) const;

  //! Returns the gradient at a point.
  Vector3D gradient(const Vector3D &point) const;

  //! Returns the gradient at a point defined by distance and direction.
  Vector3D gradient(double distance, const Vector3D &direction) const;

  //! Returns the second derivative at given distance.
  double secondDerivative(double distance) const;
};

using SphStdKernel2 = SphStdKernel<2>;

using SphStdKernel3 = SphStdKernel<3>;

//!
//! \brief Spiky N-D SPH kernel function object.
//!
//! \see Müller, Matthias, David Charypar, and Markus Gross.
//!     "Particle-based fluid simulation for interactive applications."
//!     Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
//!     animation. Eurographics Association, 2003.
//!
template <size_t N> struct SphSpikyKernel {};

template <> struct SphSpikyKernel<2> {
  //! Kernel radius.
  double h;

  //! Square of the kernel radius.
  double h2;

  //! Cubic of the kernel radius.
  double h3;

  //! Fourth-power of the kernel radius.
  double h4;

  //! Fifth-power of the kernel radius.
  double h5;

  //! Constructs a kernel object with zero radius.
  SphSpikyKernel();

  //! Constructs a kernel object with given radius.
  explicit SphSpikyKernel(double kernelRadius);

  //! Copy constructor
  SphSpikyKernel(const SphSpikyKernel &other) = default;

  //! Returns kernel function value at given distance.
  double operator()(double distance) const;

  //! Returns the first derivative at given distance.
  double firstDerivative(double distance) const;

  //! Returns the gradient at a point.
  Vector2D gradient(const Vector2D &point) const;

  //! Returns the gradient at a point defined by distance and direction.
  Vector2D gradient(double distance, const Vector2D &direction) const;

  //! Returns the second derivative at given distance.
  double secondDerivative(double distance) const;
};

template <> struct SphSpikyKernel<3> {
  //! Kernel radius.
  double h;

  //! Square of the kernel radius.
  double h2;

  //! Cubic of the kernel radius.
  double h3;

  //! Fourth-power of the kernel radius.
  double h4;

  //! Fifth-power of the kernel radius.
  double h5;

  //! Constructs a kernel object with zero radius.
  SphSpikyKernel();

  //! Constructs a kernel object with given radius.
  explicit SphSpikyKernel(double kernelRadius);

  //! Copy constructor
  SphSpikyKernel(const SphSpikyKernel &other) = default;

  //! Returns kernel function value at given distance.
  double operator()(double distance) const;

  //! Returns the first derivative at given distance.
  double firstDerivative(double distance) const;

  //! Returns the gradient at a point.
  Vector3D gradient(const Vector3D &point) const;

  //! Returns the gradient at a point defined by distance and direction.
  Vector3D gradient(double distance, const Vector3D &direction) const;

  //! Returns the second derivative at given distance.
  double secondDerivative(double distance) const;
};

using SphSpikyKernel2 = SphSpikyKernel<2>;

using SphSpikyKernel3 = SphSpikyKernel<3>;

} // namespace vox
} // namespace geometry

#include "sph_kernels-inl.h"

#endif // INCLUDE_JET_SPH_KERNELS_H_
