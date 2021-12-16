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
/*
    glTF animation channel
*/
struct AnimationChannel {
    enum PathType { TRANSLATION, ROTATION, SCALE };
    PathType path;
    Entity* node;
    uint32_t samplerIndex;
};

/*
    glTF animation sampler
*/
struct AnimationSampler {
    enum InterpolationType { LINEAR, STEP, CUBICSPLINE };
    InterpolationType interpolation;
    std::vector<float> inputs;
    std::vector<Float4> outputsVec4;
};

/*
    glTF animation
*/
struct Animation {
    std::string name;
    std::vector<AnimationSampler> samplers;
    std::vector<AnimationChannel> channels;
    float start = std::numeric_limits<float>::max();
    float end = std::numeric_limits<float>::min();
};

struct Vertex {
    Float3 pos;
    Float3 normal;
    Float2 uv;
    Float4 color;
    Float4 joint0;
    Float4 weight0;
    Float4 tangent;
};

class GLTFLoader {
public:
    std::vector<Entity*> nodes;
    std::vector<Entity*> linearNodes;

    std::vector<id<MTLTexture>> textures;
    std::vector<MaterialPtr> materials;

    std::vector<GPUSkinnedMeshRenderer::SkinPtr> skins;
    std::vector<Animation> animations;

    bool metallicRoughnessWorkflow = true;
    bool buffersBound = false;
    std::string path;
    
private:
    void loadFromFile(std::string filename, Engine* engine, float scale = 1.0f);

    void loadNode(Entity* parent, const tinygltf::Node& node, uint32_t nodeIndex,
                  const tinygltf::Model& model, float globalscale);

    void loadSkins(tinygltf::Model& gltfModel);

    void loadImages(tinygltf::Model& gltfModel, MetalRenderer* renderer);

    void loadMaterials(tinygltf::Model& gltfModel);

    void loadAnimations(tinygltf::Model& gltfModel);

    void getNodeDimensions(Entity* node, Float3& min, Float3& max);

    void getSceneDimensions();

private:
    void updateAnimation(uint32_t index, float time);

    Entity* findNode(Entity* parent, uint32_t index);

    Entity* nodeFromIndex(uint32_t index);
    
private:
    Engine* engine;
    
    id<MTLTexture> getTexture(uint32_t index);
    id<MTLTexture> emptyTexture;
    void createEmptyTexture();
};


}
}

#endif /* gltf_loader_hpp */
