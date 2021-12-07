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

#ifndef CHOBJSBOXSHAPE_H
#define CHOBJSBOXSHAPE_H

#include "chrono/assets/ChVisualization.h"
#include "chrono/geometry/ChBox.h"

namespace chrono {

/// Class for a box shape that can be visualized in some way.
class ChApi ChBoxShape : public ChVisualization {
  protected:
    geometry::ChBox gbox;

  public:
    ChBoxShape() {}
    ChBoxShape(const geometry::ChBox& mbox) : gbox(mbox) {}

    virtual ~ChBoxShape() {}

    // Access the sphere geometry
    geometry::ChBox& GetBoxGeometry() { return gbox; }

    /// Method to allow serialization of transient data to archives.
    virtual void ArchiveOUT(ChArchiveOut& marchive) override;

    /// Method to allow de-serialization of transient data from archives.
    virtual void ArchiveIN(ChArchiveIn& marchive) override;
};

CH_CLASS_VERSION(ChBoxShape, 0)

}  // end namespace chrono

#endif
