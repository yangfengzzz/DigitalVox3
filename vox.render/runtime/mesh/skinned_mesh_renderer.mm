//
//  skinned_mesh_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#include "skinned_mesh_renderer.h"
#include "../animation/blending_job.h"
#include "../animation/local_to_model_job.h"
#include "../entity.h"
#include "../animator.h"
#include "../../offline/anim_loader.h"
#include "../../offline/fbx_loader.h"
#include "../../log.h"

namespace vox {
SkinnedMeshRenderer::SkinnedMeshRenderer(Entity* entity):
MeshRenderer(entity){
    animator = entity->getComponent<Animator>();
}

bool SkinnedMeshRenderer::loadSkeleton(const std::string& filename) {
    // Reading skeleton.
    if (!vox::offline::loader::LoadSkeleton(filename.c_str(), &skeleton_)) {
        return false;
    }
    
    // Allocates runtime buffers.
    const int num_joints = skeleton_.num_joints();
    const int num_soa_joints = skeleton_.num_soa_joints();
    
    // Allocates local space runtime buffers of blended data.
    blended_locals_.resize(num_soa_joints);
    
    // Allocates model space runtime buffers of blended data.
    models_.resize(num_joints);
    
    return true;
}

bool SkinnedMeshRenderer::addSkinnedMesh(const std::string& skin_filename,
                                         const std::string& skel_filename) {
    if (models_.size() == 0) {
        loadSkeleton(skel_filename);
    }
    
    vox::vector<vox::offline::loader::Mesh> meshes;
    
    // Reading skinned meshes.
    if (!vox::offline::loader::loadScene(skin_filename.c_str(), skeleton_, meshes)) {
        return false;
    }
    // Check the skeleton matches with the mesh, especially that the mesh
    // doesn't expect more joints than the skeleton has.
    const int num_joints = skeleton_.num_joints();
    for (const vox::offline::loader::Mesh &mesh: meshes) {
        if (num_joints < mesh.highest_joint_index()) {
            vox::log::Err() << "The provided mesh doesn't match skeleton "
            "(joint count mismatch)."
            << std::endl;
            return false;
        }
    }
    
    meshes_.insert(meshes_.end(), meshes.begin(), meshes.end());
    // Computes the number of skinning matrices required to skin all meshes.
    // A mesh is skinned by only a subset of joints, so the number of skinning
    // matrices might be less that the number of skeleton joints.
    // Mesh::joint_remaps is used to know how to order skinning matrices. So the
    // number of matrices required is the size of joint_remaps.
    size_t num_skinning_matrices = 0;
    for (const vox::offline::loader::Mesh &mesh: meshes_) {
        num_skinning_matrices = vox::math::Max(num_skinning_matrices, mesh.joint_remaps.size());
    }
    
    // Allocates skinning matrices.
    skinning_matrices_.resize(num_skinning_matrices);
    
    return true;
}

void SkinnedMeshRenderer::update(float deltaTime) {
    // Setups blending job.
    vox::animation::BlendingJob blend_job;
    blend_job.threshold = threshold_;
    blend_job.layers = animator->layers();
    blend_job.bind_pose = skeleton_.joint_bind_poses();
    blend_job.output = make_span(blended_locals_);
    
    // Blends.
    if (!blend_job.Run()) {
        return;
    }
    
    // Converts from local space to model space matrices.
    // Gets the output of the blending stage, and converts it to model space.
    
    // Setup local-to-model conversion job.
    vox::animation::LocalToModelJob ltm_job;
    ltm_job.skeleton = &skeleton_;
    ltm_job.input = make_span(blended_locals_);
    ltm_job.output = make_span(models_);
    
    // Runs ltm job.
    if (!ltm_job.Run()) {
        return;
    }
}

void SkinnedMeshRenderer::_render(Camera* camera) {
    
}

void SkinnedMeshRenderer::_updateBounds(BoundingBox& worldBounds) {
    SkinnedMeshRenderer::computeSkeletonBounds(skeleton_, &worldBounds);
}

void SkinnedMeshRenderer::computeSkeletonBounds(const animation::Skeleton& _skeleton,
                                                math::BoundingBox* _bound) {
    using vox::math::Float4x4;
    
    assert(_bound);
    
    // Set a default box.
    *_bound = vox::math::BoundingBox();
    
    const int num_joints = _skeleton.num_joints();
    if (!num_joints) {
        return;
    }
    
    // Allocate matrix array, out of memory is handled by the LocalToModelJob.
    vox::vector<vox::math::Float4x4> models(num_joints);
    
    // Compute model space bind pose.
    vox::animation::LocalToModelJob job;
    job.input = _skeleton.joint_bind_poses();
    job.output = make_span(models);
    job.skeleton = &_skeleton;
    if (job.Run()) {
        // Forwards to posture function.
        SkinnedMeshRenderer::computePostureBounds(job.output, _bound);
    }
}

void SkinnedMeshRenderer::computePostureBounds(vox::span<const vox::math::Float4x4> _matrices,
                                               math::BoundingBox* _bound) {
    assert(_bound);
    
    // Set a default box.
    *_bound = vox::math::BoundingBox();
    
    if (_matrices.empty()) {
        return;
    }
    
    // Loops through matrices and stores min/max.
    // Matrices array cannot be empty, it was checked at the beginning of the
    // function.
    const vox::math::Float4x4* current = _matrices.begin();
    math::SimdFloat4 min = current->cols[3];
    math::SimdFloat4 max = current->cols[3];
    ++current;
    while (current < _matrices.end()) {
        min = math::Min(min, current->cols[3]);
        max = math::Max(max, current->cols[3]);
        ++current;
    }
    
    // Stores in math::Box structure.
    math::Store3PtrU(min, &_bound->min.x);
    math::Store3PtrU(max, &_bound->max.x);
    
    return;
    
}

}
