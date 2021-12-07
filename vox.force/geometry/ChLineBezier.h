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
// Authors: Radu Serban
// =============================================================================
//
// Geometric object representing a piecewise cubic Bezier curve in 3D.
//
// =============================================================================

#ifndef CHC_LINE_BEZIER_H
#define CHC_LINE_BEZIER_H

#include <cmath>

#include "chrono/core/ChBezierCurve.h"
#include "chrono/geometry/ChLine.h"

namespace chrono {
namespace geometry {

/// Geometric object representing a piecewise cubic Bezier curve in 3D.
class ChApi ChLineBezier : public ChLine {
  public:
    ChLineBezier() {}
    ChLineBezier(std::shared_ptr<ChBezierCurve> path);
    ChLineBezier(const std::string& filename);
    ChLineBezier(const ChLineBezier& source);
    ~ChLineBezier() {}

    /// "Virtual" copy constructor (covariant return type).
    virtual ChLineBezier* Clone() const override { return new ChLineBezier(*this); }

    virtual GeometryType GetClassType() const override { return LINE_BEZIER; }

    virtual void Set_closed(bool mc) override {}
    virtual void Set_complexity(int mc) override {}

    /// Curve evaluation (only parU is used, in 0..1 range)
    virtual void Evaluate(ChVector<>& pos, const double parU) const override;

    /// Method to allow serialization of transient data to archives.
    virtual void ArchiveOUT(ChArchiveOut& marchive) override;

    /// Method to allow de-serialization of transient data from archives.
    virtual void ArchiveIN(ChArchiveIn& marchive) override;

  private:
    std::shared_ptr<ChBezierCurve> m_path;  ///< handle to a Bezier curve
};

}  // end of namespace geometry

CH_CLASS_VERSION(geometry::ChLineBezier, 0)

}  // end of namespace chrono

#endif
