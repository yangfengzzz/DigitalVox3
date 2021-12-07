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

#ifndef CHCYLINDERSHAPE_H
#define CHCYLINDERSHAPE_H

#include "assets/ChVisualization.h"
#include "geometry/ChCylinder.h"

namespace chrono {

/// Class for referencing a cylinder shape that can be visualized in some way.
class ChApi ChCylinderShape : public ChVisualization {
  protected:
    geometry::ChCylinder gcylinder;

  public:
    ChCylinderShape() {}
    ChCylinderShape(const geometry::ChCylinder& mcyl) : gcylinder(mcyl) {}

    virtual ~ChCylinderShape(){};

    // Access the sphere geometry
    geometry::ChCylinder& GetCylinderGeometry() { return gcylinder; }

    /// Method to allow serialization of transient data to archives.
    virtual void ArchiveOUT(ChArchiveOut& marchive) override;

    /// Method to allow de-serialization of transient data from archives.
    virtual void ArchiveIN(ChArchiveIn& marchive) override;
};

CH_CLASS_VERSION(ChCylinderShape, 0)

}  // end namespace chrono

#endif
