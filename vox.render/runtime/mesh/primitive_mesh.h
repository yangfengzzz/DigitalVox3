//
//  primitive_mesh.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef primitive_mesh_hpp
#define primitive_mesh_hpp

#include "model_mesh.h"

namespace vox {
/**
 * Used to generate common primitive meshes.
 */
class PrimitiveMesh {
    /**
     * Create a sphere mesh.
     * @param engine - Engine
     * @param radius - Sphere radius
     * @param segments - Number of segments
     * @param noLongerAccessible - No longer access the vertices of the mesh after creation
     * @returns Sphere model mesh
     */
    static ModelMeshPtr createSphere(const EnginePtr& engine,
                                     float radius = 0.5,
                                     float segments = 18,
                                     bool noLongerAccessible = true);
    
    /**
     * Create a cuboid mesh.
     * @param engine - Engine
     * @param width - Cuboid width
     * @param height - Cuboid height
     * @param depth - Cuboid depth
     * @param noLongerAccessible - No longer access the vertices of the mesh after creation
     * @returns Cuboid model mesh
     */
    static ModelMeshPtr createCuboid(const EnginePtr& engine,
                                     float width = 1,
                                     float height = 1,
                                     float depth = 1,
                                     bool noLongerAccessible = true);
    
    
    /**
     * Create a plane mesh.
     * @param engine - Engine
     * @param width - Plane width
     * @param height - Plane height
     * @param horizontalSegments - Plane horizontal segments
     * @param verticalSegments - Plane vertical segments
     * @param noLongerAccessible - No longer access the vertices of the mesh after creation
     * @returns Plane model mesh
     */
    static ModelMeshPtr createPlane(const EnginePtr& engine,
                                    float width = 1,
                                    float height = 1,
                                    size_t horizontalSegments = 1,
                                    size_t verticalSegments = 1,
                                    bool noLongerAccessible = true);
    
    /**
     * Create a cylinder mesh.
     * @param engine - Engine
     * @param radiusTop - The radius of top cap
     * @param radiusBottom - The radius of bottom cap
     * @param height - The height of torso
     * @param radialSegments - Cylinder radial segments
     * @param heightSegments - Cylinder height segments
     * @param noLongerAccessible - No longer access the vertices of the mesh after creation
     * @returns Cylinder model mesh
     */
    static ModelMeshPtr createCylinder(const EnginePtr& engine,
                                       float radiusTop = 0.5,
                                       float radiusBottom = 0.5,
                                       float height = 2,
                                       size_t radialSegments = 20,
                                       size_t heightSegments = 1,
                                       bool noLongerAccessible = true);
    
    /**
     * Create a torus mesh.
     * @param engine - Engine
     * @param radius - Torus radius
     * @param tubeRadius - Torus tube
     * @param radialSegments - Torus radial segments
     * @param tubularSegments - Torus tubular segments
     * @param arc - Central angle
     * @param noLongerAccessible - No longer access the vertices of the mesh after creation
     * @returns Torus model mesh
     */
    static ModelMeshPtr createTorus(const EnginePtr& engine,
                                    float radius = 0.5,
                                    float tubeRadius = 0.1,
                                    size_t radialSegments = 30,
                                    size_t tubularSegments = 30,
                                    float arc = 360,
                                    bool noLongerAccessible = true);
    
    /**
     * Create a cone mesh.
     * @param engine - Engine
     * @param radius - The radius of cap
     * @param height - The height of torso
     * @param radialSegments - Cylinder radial segments
     * @param heightSegments - Cylinder height segments
     * @param noLongerAccessible - No longer access the vertices of the mesh after creation
     * @returns Cone model mesh
     */
    static ModelMeshPtr createCone(const EnginePtr& engine,
                                   float radius = 0.5,
                                   float height = 2,
                                   size_t radialSegments = 20,
                                   size_t heightSegments = 1,
                                   bool noLongerAccessible = true);
    
    /**
     * Create a capsule mesh.
     * @param engine - Engine
     * @param radius - The radius of the two hemispherical ends
     * @param height - The height of the cylindrical part, measured between the centers of the hemispherical ends
     * @param radialSegments - Hemispherical end radial segments
     * @param heightSegments - Cylindrical part height segments
     * @param noLongerAccessible - No longer access the vertices of the mesh after creation
     * @returns Capsule model mesh
     */
    static ModelMeshPtr createCapsule(const EnginePtr& engine,
                                      float radius = 0.5,
                                      float height = 2,
                                      size_t radialSegments = 6,
                                      size_t heightSegments = 1,
                                      bool noLongerAccessible = true);
    
private:
    static void _createCapsuleCap(float radius,
                                  float height,
                                  size_t radialSegments,
                                  float capAlphaRange,
                                  size_t offset,
                                  size_t posIndex,
                                  std::vector<Float3>& positions,
                                  std::vector<Float3>& normals,
                                  std::vector<Float2>& uvs,
                                  std::vector<uint32_t>& indices,
                                  size_t indicesOffset);
    
    static void _initialize(const ModelMeshPtr& mesh,
                            const std::vector<Float3>& positions,
                            const std::vector<Float3>& normals,
                            std::vector<Float2>& uvs,
                            const std::vector<uint32_t>& indices,
                            bool noLongerAccessible);
};

}

#endif /* primitive_mesh_hpp */
