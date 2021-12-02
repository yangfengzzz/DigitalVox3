//
//  skinned_mesh_renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#include "skinned_mesh_renderer.h"
#include "buffer_mesh.h"
#include "../animation/blending_job.h"
#include "../animation/local_to_model_job.h"
#include "../entity.h"
#include "../animator.h"
#include "../../geometry/skinning_job.h"
#include "../../offline/anim_loader.h"
#include "../../offline/fbx_loader.h"
#include "../../log.h"
#include "../engine.h"
#include "../camera.h"
#include <MetalKit/MetalKit.h>

namespace vox {
SkinnedMeshRenderer::SkinnedMeshRenderer(Entity* entity):
Renderer(entity){
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
    blend_job.bind_pose = skeleton_.joint_bind_poses();
    blend_job.output = make_span(blended_locals_);
    if (animator != nullptr) {
        blend_job.layers = animator->layers();
    }
    
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
    // Builds skinning matrices, based on the output of the animation stage.
    // The mesh might not use (aka be skinned by) all skeleton joints. We use
    // the joint remapping table (available from the mesh object) to reorder
    // model-space matrices and build skinning ones.
    for (size_t index = 0; index < meshes_.size(); index++) {
        const auto &mesh = meshes_[index];
        for (size_t i = 0; i < mesh.joint_remaps.size(); ++i) {
            skinning_matrices_[i] = models_[mesh.joint_remaps[i]] * mesh.inverse_bind_poses[i];
        }
        
        // Renders skin.
        auto render_mesh = drawSkinnedMesh(index, mesh, make_span(skinning_matrices_), vox::math::Float4x4::identity());
        auto& subMeshes = render_mesh->_subMeshes;
        auto& renderPipeline = camera->_renderPipeline;
        for (size_t i = 0; i < subMeshes.size(); i++) {
            MaterialPtr material;
            if (i < _materials.size()) {
                material = _materials[i];
            } else {
                material = nullptr;
            }
            if (material != nullptr) {
                RenderElement element(this, render_mesh, &subMeshes[i], material);
                renderPipeline.pushPrimitive(element);
            }
        }
    }
}

namespace {
// Volatile memory buffer that can be used within function scope.
// Minimum alignment is 16 bytes.
class ScratchBuffer {
public:
    ScratchBuffer() : buffer_(nullptr), size_(0) {
    }
    
    ~ScratchBuffer() {
        vox::memory::default_allocator()->Deallocate(buffer_);
    }
    
    // Resizes the buffer to the new size and return the memory address.
    void *Resize(size_t _size) {
        if (_size > size_) {
            size_ = _size;
            vox::memory::default_allocator()->Deallocate(buffer_);
            buffer_ = vox::memory::default_allocator()->Allocate(_size, 16);
        }
        return buffer_;
    }
    
private:
    void *buffer_;
    size_t size_;
};

const float kDefaultUVsArray[][2] = {
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
    {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}};
} // namespace

std::shared_ptr<Mesh> SkinnedMeshRenderer::drawSkinnedMesh(size_t index,
                                                           const vox::offline::loader::Mesh& _mesh,
                                                           const span<math::Float4x4> _skinning_matrices,
                                                           const vox::math::Float4x4& _transform) {
    ScratchBuffer vbo_buffer_;
    ScratchBuffer uv_buffer_;
    const int vertex_count = _mesh.vertex_count();
    
    MDLVertexDescriptor *vertexDescriptor = [[MDLVertexDescriptor alloc] init];
    
    // Positions and normals are interleaved to improve caching while executing
    // skinning job.
    const int32_t positions_offset = 0;
    const int32_t normals_offset = sizeof(float) * 3;
    const int32_t tangents_offset = sizeof(float) * 6;
    const int32_t positions_stride = sizeof(float) * 9;
    const int32_t normals_stride = positions_stride;
    const int32_t tangents_stride = positions_stride;
    const int32_t skinned_data_size = vertex_count * positions_stride;
    void *vbo_map = vbo_buffer_.Resize(skinned_data_size);
    vertexDescriptor.attributes[0] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributePosition
                                                                       format:MDLVertexFormatFloat3 offset:positions_offset bufferIndex:0];
    vertexDescriptor.attributes[1] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeNormal
                                                                       format:MDLVertexFormatFloat3 offset:normals_offset bufferIndex:0];
    vertexDescriptor.attributes[2] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeTangent
                                                                       format:MDLVertexFormatFloat3 offset:tangents_offset bufferIndex:0];
    
    // Colors and uvs are contiguous. They aren't transformed, so they can be
    // directly copied from source mesh which is non-interleaved as-well.
    // Colors will be filled with white if _options.colors is false.
    // UVs will be skipped if _options.textured is false.
    const int32_t uvs_offset = 0;
    const int32_t uvs_stride = sizeof(float) * 2;
    const int32_t uvs_size = vertex_count * uvs_stride;
    void *uv_map = uv_buffer_.Resize(uvs_size);
    vertexDescriptor.attributes[3] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeTextureCoordinate
                                                                       format:MDLVertexFormatFloat2 offset:uvs_offset bufferIndex:1];
    vertexDescriptor.layouts[0] = [[MDLVertexBufferLayout alloc] initWithStride:positions_stride];
    vertexDescriptor.layouts[1] = [[MDLVertexBufferLayout alloc] initWithStride:uvs_stride];
    
    
    // Iterate mesh parts and fills vbo.
    // Runs a skinning job per mesh part. Triangle indices are shared
    // across parts.
    size_t processed_vertex_count = 0;
    for (size_t i = 0; i < _mesh.parts.size(); ++i) {
        const vox::offline::loader::Mesh::Part &part = _mesh.parts[i];
        
        // Skip this iteration if no vertex.
        const size_t part_vertex_count = part.positions.size() / 3;
        if (part_vertex_count == 0) {
            continue;
        }
        
        // Fills the job.
        vox::geometry::SkinningJob skinning_job;
        skinning_job.vertex_count = static_cast<int>(part_vertex_count);
        const int part_influences_count = part.influences_count();
        
        // Clamps joints influence count according to the option.
        skinning_job.influences_count = part_influences_count;
        
        // Setup skinning matrices, that came from the animation stage before being
        // multiplied by inverse model-space bind-pose.
        skinning_job.joint_matrices = _skinning_matrices;
        
        // Setup joint's indices.
        skinning_job.joint_indices = make_span(part.joint_indices);
        skinning_job.joint_indices_stride =
        sizeof(uint16_t) * part_influences_count;
        
        // Setup joint's weights.
        if (part_influences_count > 1) {
            skinning_job.joint_weights = make_span(part.joint_weights);
            skinning_job.joint_weights_stride =
            sizeof(float) * (part_influences_count - 1);
        }
        
        // Setup input positions, coming from the loaded mesh.
        skinning_job.in_positions = make_span(part.positions);
        skinning_job.in_positions_stride =
        sizeof(float) * vox::offline::loader::Mesh::Part::kPositionsCpnts;
        
        // Setup output positions, coming from the rendering output mesh buffers.
        // We need to offset the buffer every loop.
        float *out_positions_begin = reinterpret_cast<float *>(vox::PointerStride(vbo_map,
                                                                                  positions_offset + processed_vertex_count * positions_stride));
        float *out_positions_end = vox::PointerStride(
                                                      out_positions_begin, part_vertex_count * positions_stride);
        skinning_job.out_positions = {out_positions_begin, out_positions_end};
        skinning_job.out_positions_stride = positions_stride;
        
        // Setup normals if input are provided.
        float *out_normal_begin = reinterpret_cast<float *>(vox::PointerStride(vbo_map,
                                                                               normals_offset + processed_vertex_count * normals_stride));
        float *out_normal_end = vox::PointerStride(out_normal_begin, part_vertex_count * normals_stride);
        
        if (part.normals.size() / vox::offline::loader::Mesh::Part::kNormalsCpnts ==
            part_vertex_count) {
            // Setup input normals, coming from the loaded mesh.
            skinning_job.in_normals = make_span(part.normals);
            skinning_job.in_normals_stride =
            sizeof(float) * vox::offline::loader::Mesh::Part::kNormalsCpnts;
            
            // Setup output normals, coming from the rendering output mesh buffers.
            // We need to offset the buffer every loop.
            skinning_job.out_normals = {out_normal_begin, out_normal_end};
            skinning_job.out_normals_stride = normals_stride;
        } else {
            // Fills output with default normals.
            for (float *normal = out_normal_begin; normal < out_normal_end;
                 normal = vox::PointerStride(normal, normals_stride)) {
                normal[0] = 0.f;
                normal[1] = 1.f;
                normal[2] = 0.f;
            }
        }
        
        // Setup tangents if input are provided.
        float *out_tangent_begin = reinterpret_cast<float *>(vox::PointerStride(vbo_map,
                                                                                tangents_offset + processed_vertex_count * tangents_stride));
        float *out_tangent_end = vox::PointerStride(out_tangent_begin, part_vertex_count * tangents_stride);
        
        if (part.tangents.size() / vox::offline::loader::Mesh::Part::kTangentsCpnts ==
            part_vertex_count) {
            // Setup input tangents, coming from the loaded mesh.
            skinning_job.in_tangents = make_span(part.tangents);
            skinning_job.in_tangents_stride =
            sizeof(float) * vox::offline::loader::Mesh::Part::kTangentsCpnts;
            
            // Setup output tangents, coming from the rendering output mesh buffers.
            // We need to offset the buffer every loop.
            skinning_job.out_tangents = {out_tangent_begin, out_tangent_end};
            skinning_job.out_tangents_stride = tangents_stride;
        } else {
            // Fills output with default tangents.
            for (float *tangent = out_tangent_begin; tangent < out_tangent_end;
                 tangent = vox::PointerStride(tangent, tangents_stride)) {
                tangent[0] = 1.f;
                tangent[1] = 0.f;
                tangent[2] = 0.f;
            }
        }
        
        // Execute the job, which should succeed unless a parameter is invalid.
        if (!skinning_job.Run()) {
            return nullptr;
        }
        
        // Copies uvs which aren't affected by skinning.
        if (true) {
            if (part_vertex_count == part.uvs.size() / vox::offline::loader::Mesh::Part::kUVsCpnts) {
                // Optimal path used when the right number of uvs is provided.
                memcpy(vox::PointerStride(uv_map, uvs_offset + processed_vertex_count * uvs_stride),
                       array_begin(part.uvs), part_vertex_count * uvs_stride);
            } else {
                // Un-optimal path used when the right number of uvs is not provided.
                assert(sizeof(kDefaultUVsArray[0]) == uvs_stride);
                for (size_t j = 0; j < part_vertex_count;
                     j += VOX_ARRAY_SIZE(kDefaultUVsArray)) {
                    const size_t this_loop_count = vox::math::Min(VOX_ARRAY_SIZE(kDefaultUVsArray), part_vertex_count - j);
                    memcpy(vox::PointerStride(uv_map, uvs_offset + (processed_vertex_count + j) * uvs_stride),
                           kDefaultUVsArray, uvs_stride * this_loop_count);
                }
            }
        }
        
        // Some more vertices were processed.
        processed_vertex_count += part_vertex_count;
    }
    
    const auto& device = engine()->_hardwareRenderer.device;
    if (vertexBuffers[index] == nullptr) {
        vertexBuffers[index] = [device newBufferWithBytes:vbo_map length:skinned_data_size options:NULL];
    } else {
        memcpy([vertexBuffers[index] contents], vbo_map, skinned_data_size);
    }
    
    if (uvBuffers[index] == nullptr) {
        uvBuffers[index] = [device newBufferWithBytes:uv_map length:uvs_size options:NULL];
    } else {
        memcpy([uvBuffers[index] contents], uv_map, uvs_size);
    }
    
    size_t indexCount = _mesh.triangle_indices.size();
    if (indexBuffers[index] == nullptr) {
        indexBuffers[index] = [device newBufferWithBytes: _mesh.triangle_indices.data()
                                                  length: indexCount * sizeof(vox::offline::loader::Mesh::TriangleIndices::value_type)
                                                 options: NULL];
    }
    
    auto mesh = std::make_shared<BufferMesh>(_engine);
    mesh->setVertexDescriptor(vertexDescriptor);
    mesh->setVertexBufferBinding(vertexBuffers[index], 0, 0);
    mesh->setVertexBufferBinding(uvBuffers[index], 0, 1);
    mesh->addSubMesh(MeshBuffer(indexBuffers[index],
                                indexCount * sizeof(vox::offline::loader::Mesh::TriangleIndices::value_type),
                                MDLMeshBufferTypeIndex),
                     MTLIndexTypeUInt16, indexCount, MTLPrimitiveTypeTriangle);
    
    return mesh;
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

int SkinnedMeshRenderer::numJoints() {
    return skeleton_.num_joints();
}

int SkinnedMeshRenderer::numSoaJoints() {
    return skeleton_.num_soa_joints();
}

}
