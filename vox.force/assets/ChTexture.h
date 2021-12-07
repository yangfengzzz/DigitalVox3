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

#ifndef CHTEXTURE_H
#define CHTEXTURE_H

#include "chrono/assets/ChAsset.h"

namespace chrono {

/// Base class for assets that define basic textures. Assets can be attached to ChBody objects.
/// Different post processing modules can handle textures in proper ways (ex for ray tracing, or
/// openGL visualization), or may also create specialized classes of textures with more properties.
class ChApi ChTexture : public ChAsset {
  protected:
    std::string filename;
    float scale_x;
    float scale_y;

  public:
    ChTexture() : scale_x(1), scale_y(1) { filename = ""; }
    ChTexture(const char* mfilename) : scale_x(1), scale_y(1) { filename = mfilename; }
    ChTexture(const std::string& mfilename) : scale_x(1), scale_y(1) { filename = mfilename; }

    virtual ~ChTexture() {}

    // Get the texture filename. This information could be used by visualization postprocessing.
    const std::string& GetTextureFilename() const { return filename; }
    // Set the texture filename. This information could be used by visualization postprocessing.
    void SetTextureFilename(const std::string& mfile) { filename = mfile; }
    // Set the texture scale
    void SetTextureScale(float sx, float sy) {
        scale_x = sx;
        scale_y = sy;
    }
    // Get the texture scales (in X and Y directions)
    float GetTextureScaleX() const { return scale_x; }
    float GetTextureScaleY() const { return scale_y; }

    /// Method to allow serialization of transient data to archives.
    virtual void ArchiveOUT(ChArchiveOut& marchive) override;

    /// Method to allow de-serialization of transient data from archives.
    virtual void ArchiveIN(ChArchiveIn& marchive) override;
};

CH_CLASS_VERSION(ChTexture, 0)

}  // end namespace chrono

#endif
