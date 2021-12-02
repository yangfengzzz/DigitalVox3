//
//  skinned_mesh_renderer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#ifndef skinned_mesh_renderer_hpp
#define skinned_mesh_renderer_hpp

#include "mesh_renderer.h"
#include "../animation/skeleton.h"
#include "../../containers/vector.h"
#include "../../offline/fbx_mesh.h"

namespace vox {
class SkinnedMeshRenderer : public MeshRenderer {
public:
    SkinnedMeshRenderer(Entity* entity);
    
    void update(float deltaTime) override;
    
    bool loadSkeleton(const std::string& filename);
    
    bool addSkinnedMesh(const std::string& skin_filename,
                        const std::string& skel_filename);

private:
    Animator* animator;
    
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
