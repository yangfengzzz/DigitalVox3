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
    for (tinygltf::Animation &anim : gltfModel.animations) {
        Animation animation{};
        animation.name = anim.name;
        if (anim.name.empty()) {
            animation.name = std::to_string(animations.size());
        }
        
        // Samplers
        for (auto &samp : anim.samplers) {
            AnimationSampler sampler{};
            
            if (samp.interpolation == "LINEAR") {
                sampler.interpolation = AnimationSampler::InterpolationType::LINEAR;
            }
            if (samp.interpolation == "STEP") {
                sampler.interpolation = AnimationSampler::InterpolationType::STEP;
            }
            if (samp.interpolation == "CUBICSPLINE") {
                sampler.interpolation = AnimationSampler::InterpolationType::CUBICSPLINE;
            }
            
            // Read sampler input time values
            {
                const tinygltf::Accessor &accessor = gltfModel.accessors[samp.input];
                const tinygltf::BufferView &bufferView = gltfModel.bufferViews[accessor.bufferView];
                const tinygltf::Buffer &buffer = gltfModel.buffers[bufferView.buffer];
                
                assert(accessor.componentType == TINYGLTF_COMPONENT_TYPE_FLOAT);
                
                float *buf = new float[accessor.count];
                memcpy(buf, &buffer.data[accessor.byteOffset + bufferView.byteOffset], accessor.count * sizeof(float));
                for (size_t index = 0; index < accessor.count; index++) {
                    sampler.inputs.push_back(buf[index]);
                }
                
                for (auto input : sampler.inputs) {
                    if (input < animation.start) {
                        animation.start = input;
                    };
                    if (input > animation.end) {
                        animation.end = input;
                    }
                }
            }
            
            // Read sampler output T/R/S values
            {
                const tinygltf::Accessor &accessor = gltfModel.accessors[samp.output];
                const tinygltf::BufferView &bufferView = gltfModel.bufferViews[accessor.bufferView];
                const tinygltf::Buffer &buffer = gltfModel.buffers[bufferView.buffer];
                
                assert(accessor.componentType == TINYGLTF_COMPONENT_TYPE_FLOAT);
                
                switch (accessor.type) {
                    case TINYGLTF_TYPE_VEC3: {
                        std::vector<Float3> buf(accessor.count);
                        memcpy(buf.data(), &buffer.data[accessor.byteOffset + bufferView.byteOffset], accessor.count * sizeof(Float3));
                        for (size_t index = 0; index < accessor.count; index++) {
                            sampler.outputsVec4.push_back(Float4(buf[index], 0.0f));
                        }
                        break;
                    }
                    case TINYGLTF_TYPE_VEC4: {
                        std::vector<Float4> buf(accessor.count);
                        memcpy(buf.data(), &buffer.data[accessor.byteOffset + bufferView.byteOffset], accessor.count * sizeof(Float4));
                        for (size_t index = 0; index < accessor.count; index++) {
                            sampler.outputsVec4.push_back(buf[index]);
                        }
                        break;
                    }
                    default: {
                        std::cout << "unknown type" << std::endl;
                        break;
                    }
                }
            }
            
            animation.samplers.push_back(sampler);
        }
        
        // Channels
        for (auto &source: anim.channels) {
            AnimationChannel channel{};
            
            if (source.target_path == "rotation") {
                channel.path = AnimationChannel::PathType::ROTATION;
            }
            if (source.target_path == "translation") {
                channel.path = AnimationChannel::PathType::TRANSLATION;
            }
            if (source.target_path == "scale") {
                channel.path = AnimationChannel::PathType::SCALE;
            }
            if (source.target_path == "weights") {
                std::cout << "weights not yet supported, skipping channel" << std::endl;
                continue;
            }
            channel.samplerIndex = source.sampler;
            channel.node = nodeFromIndex(source.target_node);
            if (!channel.node) {
                continue;
            }
            
            animation.channels.push_back(channel);
        }
        
        animations.push_back(animation);
    }
}

void GLTFLoader::getNodeDimensions(Entity* node, Float3& min, Float3& max) {
    
}

void GLTFLoader::getSceneDimensions() {
    
}


}
}
