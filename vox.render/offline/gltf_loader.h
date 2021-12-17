//
//  gltf_loader.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/15.
//

#ifndef gltf_loader_hpp
#define gltf_loader_hpp

#include "../runtime/mesh/gpu_skinned_mesh_renderer.h"
#include "../runtime/entity.h"
#include <Metal/Metal.h>

#define TINYGLTF_NO_STB_IMAGE_WRITE
#include "tiny_gltf.h"

namespace vox {
namespace offline {

class GLTFLoader {
public:
    EntityPtr defaultSceneRoot;

    std::vector<id<MTLTexture>> textures;
    std::vector<MaterialPtr> materials;
    std::vector<GPUSkinnedMeshRenderer::SkinPtr> skins;
    
    GLTFLoader(Engine* engine);
    
    void loadFromFile(std::string filename, float scale = 1.0f);

private:
    void loadNode(EntityPtr parent, const tinygltf::Node& node, uint32_t nodeIndex,
                  const tinygltf::Model& model, float globalscale);

    void loadImages(tinygltf::Model& gltfModel, MetalRenderer* renderer);

    void loadMaterials(tinygltf::Model& gltfModel);

    void loadSkins(tinygltf::Model& gltfModel);
    
private:
    Engine* engine;
    std::map<uint32_t, std::pair<EntityPtr, int32_t>> linearNodes{};
    bool metallicRoughnessWorkflow = true;
    std::string path;
};


}
}

#endif /* gltf_loader_hpp */
