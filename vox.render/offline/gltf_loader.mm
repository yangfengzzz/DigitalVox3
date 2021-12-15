//
//  gltf_loader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/15.
//

#include "gltf_loader.h"

namespace vox {
namespace offline {
void GLTFLoader::loadFromFile(std::string filename, uint32_t fileLoadingFlags, float scale) {
    
}

void GLTFLoader::loadNode(Entity* parent, const tinygltf::Node& node, uint32_t nodeIndex, const tinygltf::Model& model,
                          std::vector<uint32_t>& indexBuffer, std::vector<Vertex>& vertexBuffer, float globalscale) {
    
}

void GLTFLoader::loadSkins(tinygltf::Model& gltfModel) {
    
}

void GLTFLoader::loadImages(tinygltf::Model& gltfModel) {
    
}

void GLTFLoader::loadMaterials(tinygltf::Model& gltfModel) {
    
}

void GLTFLoader::loadAnimations(tinygltf::Model& gltfModel) {
    
}

void GLTFLoader::getNodeDimensions(Entity* node, Float3& min, Float3& max) {
    
}

void GLTFLoader::getSceneDimensions() {
    
}


}
}
