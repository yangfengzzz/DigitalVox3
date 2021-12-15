//
//  gltf_loader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/15.
//

#include "gltf_loader.h"
#include "../runtime/engine.h"
#include "../runtime/rhi-metal/metal_renderer.h"
#include "../runtime/mesh/buffer_mesh.h"
#include <iostream>

namespace vox {
namespace offline {
void GLTFLoader::loadFromFile(std::string filename, Engine* engine, float scale) {
    tinygltf::Model gltfModel;
    tinygltf::TinyGLTF gltfContext;
    gltfContext.SetImageLoader(tinygltf::LoadImageData, nullptr);
    
    size_t pos = filename.find_last_of('/');
    path = filename.substr(0, pos);
    
    std::string error, warning;
    
    this->renderer = &engine->_hardwareRenderer;
    
    bool fileLoaded = gltfContext.LoadASCIIFromFile(&gltfModel, &error, &warning, filename);
    
    std::vector<uint32_t> indexBuffer;
    std::vector<Vertex> vertexBuffer;
    
    if (fileLoaded) {
        loadImages(gltfModel, renderer);
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
        
        // for (auto node : linearNodes) {
        // Assign skins
        // if (node->skinIndex > -1) {
        //     node->skin = skins[node->skinIndex];
        // }
        // Initial pose
        // if (node->mesh) {
        //     node->update();
        // }
        // }
    }
    else {
        // TODO: throw
        std::cerr << "Could not load glTF file \"" + filename + "\": " + error << std::endl;
        return;
    }
    
    for (auto extension : gltfModel.extensionsUsed) {
        if (extension == "KHR_materials_pbrSpecularGlossiness") {
            std::cout << "Required extension: " << extension;
            metallicRoughnessWorkflow = false;
        }
    }
    
    size_t vertexBufferSize = vertexBuffer.size() * sizeof(Vertex);
    size_t indexBufferSize = indexBuffer.size() * sizeof(uint32_t);
    
    auto vBuffer = [renderer->device newBufferWithBytes:vertexBuffer.data() length:vertexBufferSize options:NULL];
    auto iBuffer = [renderer->device newBufferWithBytes:indexBuffer.data() length:indexBufferSize options:NULL];
    
    auto bufferMesh = std::make_shared<BufferMesh>(engine);
    bufferMesh->setVertexBufferBinding(vBuffer, 0, 0);
    
    bufferMesh->addSubMesh(MeshBuffer(iBuffer,
                                      indexBuffer.size() * sizeof(uint32_t),
                                      MDLMeshBufferTypeIndex),
                           MTLIndexTypeUInt32, indexBuffer.size(), MTLPrimitiveTypeTriangle);
    mesh = bufferMesh;
    
    getSceneDimensions();
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
