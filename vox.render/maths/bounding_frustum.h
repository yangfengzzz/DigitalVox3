//
//  bounding_frustum.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/25.
//

#ifndef bounding_frustum_hpp
#define bounding_frustum_hpp

#include <cassert>
#include <cmath>
#include <array>
#include "maths/math_constant.h"
#include "platform.h"
#include "plane.h"
#include "matrix.h"
#include "bounding_box.h"
#include <optional>

namespace ozz {
namespace math {
struct BoundingFrustum {
    /** The near plane of this frustum. */
    Plane near;
    /** The far plane of this frustum. */
    Plane far;
    /** The left plane of this frustum. */
    Plane left;
    /** The right plane of this frustum. */
    Plane right;
    /** The top plane of this frustum. */
    Plane top;
    /** The bottom plane of this frustum. */
    Plane bottom;
    
    /**
     * Constructor of BoundingFrustum.
     * @param matrix - The view-projection matrix
     */
    BoundingFrustum(std::optional<Matrix> matrix = std::nullopt);
    
    /**
     * Get the plane by the given index.
     * 0: near
     * 1: far
     * 2: left
     * 3: right
     * 4: top
     * 5: bottom
     * @param index - The index
     * @returns The plane get
     */
    Plane getPlane(int index) const;
    
    /**
     * Update all planes from the given matrix.
     * @param matrix - The given view-projection matrix
     */
    void calculateFromMatrix(const Matrix &matrix);
    
    /**
     * Get whether or not a specified bounding box intersects with this frustum (Contains or Intersects).
     * @param box - The box for testing
     * @returns True if bounding box intersects with this frustum, false otherwise
     */
    bool intersectsBox(const BoundingBox &box);
    
    /**
     * Get whether or not a specified bounding sphere intersects with this frustum (Contains or Intersects).
     * @param sphere - The sphere for testing
     * @returns True if bounding sphere intersects with this frustum, false otherwise
     */
    bool intersectsSphere(const BoundingSphere &sphere);
};

}
}
#endif /* bounding_frustum_hpp */
