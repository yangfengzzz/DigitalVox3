//
//  skinned_mesh_renderer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#ifndef skinned_mesh_renderer_hpp
#define skinned_mesh_renderer_hpp

#include "../renderer.h"
#include "../animation/skeleton.h"
#include "../../containers/vector.h"
#include "../../offline/fbx_mesh.h"
#include "maths/soa_transform.h"

namespace vox {
class SkinnedMeshRenderer : public Renderer {
public:
    SkinnedMeshRenderer(Entity *entity);
    
    void _render(std::vector<RenderElement> &opaqueQueue,
                 std::vector<RenderElement> &alphaTestQueue,
                 std::vector<RenderElement> &transparentQueue) override;
    
    void _updateBounds(BoundingBox &worldBounds) override;
    
    void update(float deltaTime) override;
    
    bool loadSkeleton(const std::string &filename);
    
    bool addSkinnedMesh(const std::string &skin_filename,
                        const std::string &skel_filename);
    
public:
    int numJoints();
    
    int numSoaJoints();
    
private:
    // Computes the bounding box of _skeleton. This is the box that encloses all
    // skeleton's joints in model space.
    // _bound must be a valid math::Box instance.
    static void computeSkeletonBounds(const animation::Skeleton &_skeleton,
                                      math::BoundingBox *_bound);
    
    // Computes the bounding box of posture defines be _matrices range.
    // _bound must be a valid math::Box instance.
    static void computePostureBounds(vox::span<const vox::math::Float4x4> _matrices,
                                     math::BoundingBox *_bound);
    
    // Renders a skinned mesh at a specified location.
    std::shared_ptr<Mesh> drawSkinnedMesh(size_t index,
                                          const vox::offline::loader::Mesh &_mesh,
                                          const span<math::Float4x4> _skinning_matrices,
                                          const vox::math::Float4x4 &_transform);
    
private:
    Animator *animator = nullptr;
    
    // Runtime skeleton.
    vox::animation::Skeleton skeleton_;
    
    // Blending job bind pose threshold.
    float threshold_;
    
    // Buffer of local transforms which stores the blending result.
    vox::vector<vox::math::SoaTransform> blended_locals_;
    
    // Buffer of model space matrices. These are computed by the local-to-model
    // job after the blending stage.
    vox::vector<vox::math::Float4x4> models_;
    
    // Buffer of skinning matrices, result of the joint multiplication of the
    // inverse bind pose with the model space matrix.
    vox::vector<vox::math::Float4x4> skinning_matrices_;
    
    // The mesh used by the sample.
    vox::vector<vox::offline::loader::Mesh> meshes_;
    vox::vector<id <MTLBuffer>> vertexBuffers;
    vox::vector<id <MTLBuffer>> uvBuffers;
    vox::vector<id <MTLBuffer>> indexBuffers;
};

}

#endif /* skinned_mesh_renderer_hpp */
