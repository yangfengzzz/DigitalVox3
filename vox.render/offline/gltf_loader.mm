//
//  gltf_loader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/15.
//

#include "gltf_loader.h"
#include <iostream>

namespace vox {
namespace offline {
namespace {
/*
 We use a custom image loading function with tinyglTF, so we can do custom stuff loading ktx textures
 */
bool loadImageDataFunc(tinygltf::Image* image, const int imageIndex,
                       std::string* error, std::string* warning,
                       int req_width, int req_height, const unsigned char* bytes, int size, void* userData) {
    // KTX files will be handled by our own code
    if (image->uri.find_last_of(".") != std::string::npos) {
        if (image->uri.substr(image->uri.find_last_of(".") + 1) == "ktx") {
            return true;
        }
    }
    
    return tinygltf::LoadImageData(image, imageIndex, error, warning, req_width, req_height, bytes, size, userData);
}

bool loadImageDataFuncEmpty(tinygltf::Image* image, const int imageIndex,
                            std::string* error, std::string* warning,
                            int req_width, int req_height, const unsigned char* bytes, int size, void* userData) {
    // This function will be used for samples that don't require images to be loaded
    return true;
}
}

void GLTFLoader::loadFromFile(std::string filename, MetalRenderer* renderer, uint32_t fileLoadingFlags, float scale) {
    tinygltf::Model gltfModel;
    tinygltf::TinyGLTF gltfContext;
    if (fileLoadingFlags & FileLoadingFlags::DontLoadImages) {
        gltfContext.SetImageLoader(loadImageDataFuncEmpty, nullptr);
    } else {
        gltfContext.SetImageLoader(loadImageDataFunc, nullptr);
    }
    
    size_t pos = filename.find_last_of('/');
    path = filename.substr(0, pos);
    
    std::string error, warning;
    
    this->renderer = renderer;
    
    bool fileLoaded = gltfContext.LoadASCIIFromFile(&gltfModel, &error, &warning, filename);
    
    std::vector<uint32_t> indexBuffer;
    std::vector<Vertex> vertexBuffer;
    
    if (fileLoaded) {
        if (!(fileLoadingFlags & FileLoadingFlags::DontLoadImages)) {
            loadImages(gltfModel, renderer);
        }
        loadMaterials(gltfModel);
        const tinygltf::Scene &scene = gltfModel.scenes[gltfModel.defaultScene > -1 ? gltfModel.defaultScene : 0];
        for (size_t i = 0; i < scene.nodes.size(); i++) {
            const tinygltf::Node node = gltfModel.nodes[scene.nodes[i]];
            loadNode(nullptr, node, scene.nodes[i], gltfModel, indexBuffer, vertexBuffer, scale);
        }
        if (gltfModel.animations.size() > 0) {
            loadAnimations(gltfModel);
        }
        loadSkins(gltfModel);
        
        for (auto node : linearNodes) {
            // Assign skins
            // if (node->skinIndex > -1) {
            //     node->skin = skins[node->skinIndex];
            // }
            // Initial pose
            // if (node->mesh) {
            //     node->update();
            // }
        }
    }
    else {
        // TODO: throw
        std::cerr << "Could not load glTF file \"" + filename + "\": " + error << std::endl;
        return;
    }
}

void GLTFLoader::loadNode(Entity* parent, const tinygltf::Node& node, uint32_t nodeIndex, const tinygltf::Model& model,
                          std::vector<uint32_t>& indexBuffer, std::vector<Vertex>& vertexBuffer, float globalscale) {
    
}

void GLTFLoader::loadSkins(tinygltf::Model& gltfModel) {
    
}

void GLTFLoader::loadImages(tinygltf::Model& gltfModel, MetalRenderer* renderer) {
    
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
