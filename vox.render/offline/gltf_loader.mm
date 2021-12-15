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
#include "../runtime/material/pbr_material.h"

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
    
    this->engine = engine;
    
    bool fileLoaded = gltfContext.LoadASCIIFromFile(&gltfModel, &error, &warning, filename);
    
    std::vector<uint32_t> indexBuffer;
    std::vector<Vertex> vertexBuffer;
    
    if (fileLoaded) {
        loadImages(gltfModel, &engine->_hardwareRenderer);
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
    
    auto vBuffer = [engine->_hardwareRenderer.device newBufferWithBytes:vertexBuffer.data() length:vertexBufferSize options:NULL];
    auto iBuffer = [engine->_hardwareRenderer.device newBufferWithBytes:indexBuffer.data() length:indexBufferSize options:NULL];
    
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
    EntityPtr newNode = nullptr;
    if (parent) {
        newNode = parent->createChild();
    } else {
        newNode = engine->sceneManager().activeScene()->createRootEntity();
    }
    
    // Generate local node matrix
    if (node.translation.size() == 3) {
        auto translation = node.translation;
        newNode->transform->setPosition(Float3(translation[0], translation[1], translation[2]));
    }
    if (node.rotation.size() == 4) {
        auto rotation = node.rotation;
        newNode->transform->setRotationQuaternion(Quaternion(rotation[0], rotation[1], rotation[2], rotation[3]));
    }
    if (node.scale.size() == 3) {
        auto scale = node.scale;
        newNode->transform->setScale(Float3(scale[0], scale[1], scale[2]));
    }
    if (node.matrix.size() == 16) {
        auto m = Matrix();
        std::copy(node.matrix.begin(), node.matrix.end(), m.elements.data());
        newNode->transform->setLocalMatrix(m);
    }
    
    // Node with children
    if (node.children.size() > 0) {
        for (auto i = 0; i < node.children.size(); i++) {
            loadNode(newNode.get(), model.nodes[node.children[i]],
                     node.children[i], model, indexBuffer, vertexBuffer, globalscale);
        }
    }
    
    linearNodes.push_back(newNode.get());
}

void GLTFLoader::loadImages(tinygltf::Model& gltfModel, MetalRenderer* renderer) {
    for (tinygltf::Image &image : gltfModel.images) {
        textures.push_back(renderer->loadTexture(image.uri));
    }
    // Create an empty texture to be used for empty material images
    createEmptyTexture();
}

void GLTFLoader::loadMaterials(tinygltf::Model& gltfModel) {
    for (tinygltf::Material &mat : gltfModel.materials) {
        auto material = std::make_shared<PBRMaterial>(engine);
        if (mat.values.find("baseColorTexture") != mat.values.end()) {
            material->setBaseTexture(getTexture(gltfModel.textures[mat.values["baseColorTexture"].TextureIndex()].source));
        }
        // Metallic roughness workflow
        if (mat.values.find("metallicRoughnessTexture") != mat.values.end()) {
            material->setMetallicRoughnessTexture(getTexture(gltfModel.textures[mat.values["metallicRoughnessTexture"].TextureIndex()].source));
        }
        if (mat.values.find("roughnessFactor") != mat.values.end()) {
            material->setRoughness(static_cast<float>(mat.values["roughnessFactor"].Factor()));
        }
        if (mat.values.find("metallicFactor") != mat.values.end()) {
            material->setMetallic(static_cast<float>(mat.values["metallicFactor"].Factor()));
        }
        if (mat.values.find("baseColorFactor") != mat.values.end()) {
            auto color = mat.values["baseColorFactor"].ColorFactor();
            material->setBaseColor(Color(color[0], color[1], color[2], color[3]));
        }
        if (mat.additionalValues.find("normalTexture") != mat.additionalValues.end()) {
            material->setNormalTexture(getTexture(gltfModel.textures[mat.additionalValues["normalTexture"].TextureIndex()].source));
        } else {
            material->setNormalTexture(emptyTexture);
        }
        if (mat.additionalValues.find("emissiveTexture") != mat.additionalValues.end()) {
            material->setEmissiveTexture(getTexture(gltfModel.textures[mat.additionalValues["emissiveTexture"].TextureIndex()].source));
        }
        if (mat.additionalValues.find("occlusionTexture") != mat.additionalValues.end()) {
            material->setOcclusionTexture(getTexture(gltfModel.textures[mat.additionalValues["occlusionTexture"].TextureIndex()].source));
        }
        if (mat.additionalValues.find("alphaMode") != mat.additionalValues.end()) {
            tinygltf::Parameter param = mat.additionalValues["alphaMode"];
            if (param.string_value == "BLEND") {
                material->setBlendMode(BlendMode::Enum::Normal);
            }
            if (param.string_value == "MASK") {
                material->setBlendMode(BlendMode::Enum::Additive);
            }
        }
        if (mat.additionalValues.find("alphaCutoff") != mat.additionalValues.end()) {
            material->setAlphaCutoff(static_cast<float>(mat.additionalValues["alphaCutoff"].Factor()));
        }

        materials.push_back(material);
    }
    // Push a default material at the end of the list for meshes with no material assigned
    materials.push_back(std::make_shared<PBRMaterial>(engine));
}

void GLTFLoader::loadSkins(tinygltf::Model& gltfModel) {
    for (tinygltf::Skin &source : gltfModel.skins) {
        std::unique_ptr<Skin> newSkin = std::make_unique<Skin>();
        newSkin->name = source.name;
        
        // Find skeleton root node
        if (source.skeleton > -1) {
            newSkin->skeletonRoot = nodeFromIndex(source.skeleton);
        }
        
        // Find joint nodes
        for (int jointIndex : source.joints) {
            Entity* node = nodeFromIndex(jointIndex);
            if (node) {
                newSkin->joints.push_back(nodeFromIndex(jointIndex));
            }
        }
        
        // Get inverse bind matrices from buffer
        if (source.inverseBindMatrices > -1) {
            const tinygltf::Accessor &accessor = gltfModel.accessors[source.inverseBindMatrices];
            const tinygltf::BufferView &bufferView = gltfModel.bufferViews[accessor.bufferView];
            const tinygltf::Buffer &buffer = gltfModel.buffers[bufferView.buffer];
            newSkin->inverseBindMatrices.resize(accessor.count);
            memcpy(newSkin->inverseBindMatrices.data(), &buffer.data[accessor.byteOffset + bufferView.byteOffset], accessor.count * sizeof(Matrix));
        }
        
        skins.push_back(std::move(newSkin));
    }
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
