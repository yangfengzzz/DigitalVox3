// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_SPH_SYSTEM_DATA_H_
#define INCLUDE_JET_SPH_SYSTEM_DATA_H_

#include "constants.h"
#include "particle_system_data.h"

namespace vox {
namespace geometry {

//!
//! \brief      3-D SPH particle system data.
//!
//! This class extends ParticleSystemData2 to specialize the data model for SPH.
//! It includes density and pressure array as a default particle attribute, and
//! it also contains SPH utilities such as interpolation operator.
//!
template <size_t N> class SphSystemData : public ParticleSystemData<N> {
public:
  using Base = ParticleSystemData<N>;
  using Base::addScalarData;
  using Base::mass;
  using Base::neighborLists;
  using Base::neighborSearcher;
  using Base::numberOfParticles;
  using Base::positions;
  using Base::scalarDataAt;
  using Base::serialize;

  //! Constructs empty SPH system.
  SphSystemData();

  //! Constructs SPH system data with given number of particles.
  explicit SphSystemData(size_t numberOfParticles);

  //! Copy constructor.
  SphSystemData(const SphSystemData &other);

  //! Destructor.
  ~SphSystemData() override = default;

  //!
  //! \brief      Sets the radius.
  //!
  //! Sets the radius of the particle system. The radius will be interpreted
  //! as target spacing.
  //!
  void setRadius(double newRadius) override;

  //!
  //! \brief      Sets the mass of a particle.
  //!
  //! Setting the mass of a particle will change the target density.
  //!
  //! \param[in]  newMass The new mass.
  //!
  void setMass(double newMass) override;

  //! Returns the density array view (immutable).
  [[nodiscard]] ConstArrayView1<double> densities() const;

  //! Returns the density array view (mutable).
  ArrayView1<double> densities();

  //! Returns the pressure array view (immutable).
  [[nodiscard]] ConstArrayView1<double> pressures() const;

  //! Returns the pressure array view (mutable).
  ArrayView1<double> pressures();

  //!
  //! \brief Updates the density array with the latest particle positions.
  //!
  //! This function updates the density array by recalculating each particle's
  //! latest nearby particles' position.
  //!
  //! \warning You must update the neighbor searcher
  //! (SphSystemData::buildNeighborSearcher) before calling this function.
  //!
  void updateDensities();

  //! Sets the target density of this particle system.
  void setTargetDensity(double targetDensity);

  //! Returns the target density of this particle system.
  [[nodiscard]] double targetDensity() const;

  //!
  //! \brief Sets the target particle spacing in meters.
  //!
  //! Once this function is called, hash grid and density should be
  //! updated using updateHashGrid() and updateDensities).
  //!
  void setTargetSpacing(double spacing);

  //! Returns the target particle spacing in meters.
  [[nodiscard]] double targetSpacing() const;

  //!
  //! \brief Sets the relative kernel radius.
  //!
  //! Sets the relative kernel radius compared to the target particle
  //! spacing (i.e. kernel radius / target spacing).
  //! Once this function is called, hash grid and density should
  //! be updated using updateHashGrid() and updateDensities).
  //!
  void setRelativeKernelRadius(double relativeRadius);

  //!
  //! \brief Returns the relative kernel radius.
  //!
  //! Returns the relative kernel radius compared to the target particle
  //! spacing (i.e. kernel radius / target spacing).
  //!
  [[nodiscard]] double relativeKernelRadius() const;

  //!
  //! \brief Sets the absolute kernel radius.
  //!
  //! Sets the absolute kernel radius compared to the target particle
  //! spacing (i.e. relative kernel radius * target spacing).
  //! Once this function is called, hash grid and density should
  //! be updated using updateHashGrid() and updateDensities).
  //!
  void setKernelRadius(double kernelRadius);

  //! Returns the kernel radius in meters unit.
  [[nodiscard]] double kernelRadius() const;

  //! Returns sum of kernel function evaluation for each nearby particle.
  double sumOfKernelNearby(const Vector<double, N> &position) const;

  //!
  //! \brief Returns interpolated value at given origin point.
  //!
  //! Returns interpolated scalar data from the given position using
  //! standard SPH weighted average. The data array should match the
  //! particle layout. For example, density or pressure arrays can be
  //! used.
  //!
  //! \warning You must update the neighbor searcher
  //! (SphSystemData::buildNeighborSearcher) before calling this function.
  //!
  double interpolate(const Vector<double, N> &origin, const ConstArrayView1<double> &values) const;

  //!
  //! \brief Returns interpolated vector value at given origin point.
  //!
  //! Returns interpolated vector data from the given position using
  //! standard SPH weighted average. The data array should match the
  //! particle layout. For example, velocity or acceleration arrays can be
  //! used.
  //!
  //! \warning You must update the neighbor searcher
  //! (SphSystemData::buildNeighborSearcher) before calling this function.
  //!
  Vector<double, N> interpolate(const Vector<double, N> &origin,
                                const ConstArrayView1<Vector<double, N>> &values) const;

  //!
  //! Returns the gradient of the given values at i-th particle.
  //!
  //! \warning You must update the neighbor lists
  //! (SphSystemData::buildNeighborLists) before calling this function.
  //!
  Vector<double, N> gradientAt(size_t i, const ConstArrayView1<double> &values) const;

  //!
  //! Returns the laplacian of the given values at i-th particle.
  //!
  //! \warning You must update the neighbor lists
  //! (SphSystemData::buildNeighborLists) before calling this function.
  //!
  [[nodiscard]] double laplacianAt(size_t i, const ConstArrayView1<double> &values) const;

  //!
  //! Returns the laplacian of the given values at i-th particle.
  //!
  //! \warning You must update the neighbor lists
  //! (SphSystemData::buildNeighborLists) before calling this function.
  //!
  Vector<double, N> laplacianAt(size_t i, const ConstArrayView1<Vector<double, N>> &values) const;

  //! Builds neighbor searcher with kernel radius.
  void buildNeighborSearcher();

  //! Builds neighbor lists with kernel radius.
  void buildNeighborLists();

  //! Serializes this SPH system data to the buffer.
  void serialize(std::vector<uint8_t> *buffer) const override;

  //! Deserializes this SPH system data from the buffer.
  void deserialize(const std::vector<uint8_t> &buffer) override;

  //! Copies from other SPH system data.
  void set(const SphSystemData &other);

  //! Copies from other SPH system data.
  SphSystemData &operator=(const SphSystemData &other);

private:
  //! Target density of this particle system in kg/m^2.
  double _targetDensity = kWaterDensityD;

  //! Target spacing of this particle system in meters.
  double _targetSpacing = 0.1;

  //! Relative radius of SPH kernel.
  //! SPH kernel radius divided by target spacing.
  double _kernelRadiusOverTargetSpacing = 1.8;

  //! SPH kernel radius in meters.
  double _kernelRadius = 0.1;

  size_t _pressureIdx = 0;

  size_t _densityIdx = 0;

  //! Computes the mass based on the target density and spacing.
  void computeMass();
};

//! 2-D SphSystemData type.
using SphSystemData2 = SphSystemData<2>;

//! 3-D SphSystemData type.
using SphSystemData3 = SphSystemData<3>;

//! Shared pointer for the SphSystemData2 type.
using SphSystemData2Ptr = std::shared_ptr<SphSystemData2>;

//! Shared pointer for the SphSystemData3 type.
using SphSystemData3Ptr = std::shared_ptr<SphSystemData3>;

} // namespace vox
} // namespace geometry

#endif // INCLUDE_JET_SPH_SYSTEM_DATA_H_
