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

#ifndef CHOBJSHAPEFILE_H
#define CHOBJSHAPEFILE_H

#include "chrono/assets/ChVisualization.h"

namespace chrono {

/// Class for referencing a Wavefront/Alias .obj file containing a shape that can be visualized in some way.
/// The file is not load into this object: it is simply a reference to the resource on the disk.
class ChApi ChObjShapeFile : public ChVisualization {
  protected:
    std::string filename;

  public:
    ChObjShapeFile() : filename("") {}

    virtual ~ChObjShapeFile() {}

    std::string GetFilename() const { return filename; }
    void SetFilename(const std::string ms) { filename = ms; }

    /// Method to allow serialization of transient data to archives.
    virtual void ArchiveOUT(ChArchiveOut& marchive) override;

    /// Method to allow de-serialization of transient data from archives.
    virtual void ArchiveIN(ChArchiveIn& marchive) override;
};

CH_CLASS_VERSION(ChObjShapeFile, 0)

}  // end namespace chrono

#endif
