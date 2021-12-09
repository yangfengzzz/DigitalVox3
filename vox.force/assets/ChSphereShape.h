// =============================================================================
// PROJECT CHRONO - http://projectchrono.org
//
// Copyright (c) 2014 projectchrono.org
// All rights reserved.
//
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file at the top level of the distribution and at
// http://projectchrono.org/license-chrono.txt.
//
// =============================================================================
// Authors: Alessandro Tasora
// =============================================================================

#ifndef CHOBJSPHERESHAPE_H
#define CHOBJSPHERESHAPE_H

#include "assets/ChVisualization.h"
#include "geometry/ChSphere.h"

namespace chrono {

/// Class for referencing a sphere shape that can be visualized in some way.
class ChApi ChSphereShape : public ChVisualization {
  protected:
    geometry::ChSphere gsphere;

  public:
    ChSphereShape() {}
    ChSphereShape(const geometry::ChSphere& msphere) : gsphere(msphere) {}

    virtual ~ChSphereShape() {}

    // Access the sphere geometry
    geometry::ChSphere& GetSphereGeometry() { return gsphere; }

    /// Method to allow serialization of transient data to archives.
    virtual void ArchiveOUT(ChArchiveOut& marchive) override;

    /// Method to allow de-serialization of transient data from archives.
    virtual void ArchiveIN(ChArchiveIn& marchive) override;
};

CH_CLASS_VERSION(ChSphereShape, 0)

}  // end namespace chrono

#endif