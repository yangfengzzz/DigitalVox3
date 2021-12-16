//
//  gltf_loader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/15.
//

#define TINYGLTF_IMPLEMENTATION
#define TINYGLTF_NO_STB_IMAGE_WRITE
#define TINYGLTF_NO_STB_IMAGE

#include "gltf_loader.h"
#include "../runtime/engine.h"
#include "../runtime/rhi-metal/metal_renderer.h"
#include "../runtime/mesh/buffer_mesh.h"
#include "../runtime/mesh/gpu_skinned_mesh_renderer.h"
#include "../runtime/material/pbr_material.h"

#include <iostream>

namespace vox {
namespace offline {
namespace {
bool loadImageDataFuncEmpty(tinygltf::Image* image, const int imageIndex,
                            std::string* error, std::string* warning, int req_width, int req_height,
                            const unsigned char* bytes, int size, void* userData) {
    // This function will be used for samples that don't require images to be loaded
    return true;
}
}

GLTFLoader::GLTFLoader(Engine* engine):
engine(engine){
}

void GLTFLoader::loadFromFile(std::string filename, float scale) {
    size_t pos = filename.find_last_of('/');
    path = filename.substr(0, pos);
    
    tinygltf::Model gltfModel;
    tinygltf::TinyGLTF gltfContext;
    gltfContext.SetImageLoader(loadImageDataFuncEmpty, nullptr);
        
    std::string error, warning;
    
    bool fileLoaded = gltfContext.LoadASCIIFromFile(&gltfModel, &error, &warning, filename);
    if (fileLoaded) {
        loadImages(gltfModel, &engine->_hardwareRenderer);
        loadMaterials(gltfModel);
        
        const tinygltf::Scene &scene = gltfModel.scenes[gltfModel.defaultScene > -1 ? gltfModel.defaultScene : 0];
        for (size_t i = 0; i < scene.nodes.size(); i++) {
            const tinygltf::Node node = gltfModel.nodes[scene.nodes[i]];
            loadNode(nullptr, node, scene.nodes[i], gltfModel, scale);
        }
        
        loadSkins(gltfModel);
        for (auto node : linearNodes) {
            // Assign skins
            if (node.second.second > -1) {
                node.second.first->getComponent<GPUSkinnedMeshRenderer>()->setSkin(skins[node.second.second]);
            }
            // Initial pose
            auto mesh = node.second.first->getComponent<GPUSkinnedMeshRenderer>();
            if (mesh) {
                mesh->update(0);
            }
        }
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
}

void GLTFLoader::loadNode(EntityPtr parent, const tinygltf::Node& node, uint32_t nodeIndex,
                          const tinygltf::Model& model, float globalscale) {
    EntityPtr newNode = nullptr;
    if (parent) {
        newNode = parent->createChild(node.name);
    } else {
        newNode = engine->sceneManager().activeScene()->createRootEntity(node.name);
        nodes.push_back(newNode);
    }
    linearNodes[nodeIndex] = std::make_pair(newNode, node.skin);
    
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
            loadNode(newNode, model.nodes[node.children[i]],
                     node.children[i], model, globalscale);
        }
    }
    
    // Node contains mesh data
    if (node.mesh > -1) {
        const tinygltf::Mesh mesh = model.meshes[node.mesh];
        auto renderer = newNode->addComponent<GPUSkinnedMeshRenderer>();
        auto newMesh = std::make_shared<BufferMesh>(engine);
        newMesh->name = mesh.name;
        for (size_t j = 0; j < mesh.primitives.size(); j++) {
            const tinygltf::Primitive &primitive = mesh.primitives[j];
            if (primitive.indices < 0) {
                continue;
            }
            
            // Vertices
            {
                const float *bufferPos = nullptr;
                const float *bufferNormals = nullptr;
                const float *bufferTexCoords = nullptr;
                const float* bufferColors = nullptr;
                const float *bufferTangents = nullptr;
                uint32_t numColorComponents = 0;
                const uint16_t *bufferJoints = nullptr;
                const float *bufferWeights = nullptr;
                
                // Position attribute is required
                assert(primitive.attributes.find("POSITION") != primitive.attributes.end());
                
                const tinygltf::Accessor &posAccessor = model.accessors[primitive.attributes.find("POSITION")->second];
                const tinygltf::BufferView &posView = model.bufferViews[posAccessor.bufferView];
                bufferPos = reinterpret_cast<const float *>(&(model.buffers[posView.buffer].data[posAccessor.byteOffset + posView.byteOffset]));
                Float3 posMin = Float3(posAccessor.minValues[0], posAccessor.minValues[1], posAccessor.minValues[2]);
                Float3 posMax = Float3(posAccessor.maxValues[0], posAccessor.maxValues[1], posAccessor.maxValues[2]);
                newMesh->bounds = BoundingBox(posMin, posMax);
                
                if (primitive.attributes.find("NORMAL") != primitive.attributes.end()) {
                    const tinygltf::Accessor &normAccessor = model.accessors[primitive.attributes.find("NORMAL")->second];
                    const tinygltf::BufferView &normView = model.bufferViews[normAccessor.bufferView];
                    bufferNormals = reinterpret_cast<const float *>(&(model.buffers[normView.buffer].data[normAccessor.byteOffset + normView.byteOffset]));
                }
                
                if (primitive.attributes.find("TEXCOORD_0") != primitive.attributes.end()) {
                    const tinygltf::Accessor &uvAccessor = model.accessors[primitive.attributes.find("TEXCOORD_0")->second];
                    const tinygltf::BufferView &uvView = model.bufferViews[uvAccessor.bufferView];
                    bufferTexCoords = reinterpret_cast<const float *>(&(model.buffers[uvView.buffer].data[uvAccessor.byteOffset + uvView.byteOffset]));
                }
                
                if (primitive.attributes.find("COLOR_0") != primitive.attributes.end()) {
                    const tinygltf::Accessor& colorAccessor = model.accessors[primitive.attributes.find("COLOR_0")->second];
                    const tinygltf::BufferView& colorView = model.bufferViews[colorAccessor.bufferView];
                    // Color buffer are either of type vec3 or vec4
                    numColorComponents = colorAccessor.type == TINYGLTF_PARAMETER_TYPE_FLOAT_VEC3 ? 3 : 4;
                    bufferColors = reinterpret_cast<const float*>(&(model.buffers[colorView.buffer].data[colorAccessor.byteOffset + colorView.byteOffset]));
                }
                
                if (primitive.attributes.find("TANGENT") != primitive.attributes.end()) {
                    const tinygltf::Accessor &tangentAccessor = model.accessors[primitive.attributes.find("TANGENT")->second];
                    const tinygltf::BufferView &tangentView = model.bufferViews[tangentAccessor.bufferView];
                    bufferTangents = reinterpret_cast<const float *>(&(model.buffers[tangentView.buffer].data[tangentAccessor.byteOffset + tangentView.byteOffset]));
                }
                
                // Skinning
                // Joints
                if (primitive.attributes.find("JOINTS_0") != primitive.attributes.end()) {
                    // TODO data type have problem
                    const tinygltf::Accessor &jointAccessor = model.accessors[primitive.attributes.find("JOINTS_0")->second];
                    const tinygltf::BufferView &jointView = model.bufferViews[jointAccessor.bufferView];
                    bufferJoints = reinterpret_cast<const uint16_t *>(&(model.buffers[jointView.buffer].data[jointAccessor.byteOffset + jointView.byteOffset]));
                }
                
                if (primitive.attributes.find("WEIGHTS_0") != primitive.attributes.end()) {
                    const tinygltf::Accessor &uvAccessor = model.accessors[primitive.attributes.find("WEIGHTS_0")->second];
                    const tinygltf::BufferView &uvView = model.bufferViews[uvAccessor.bufferView];
                    bufferWeights = reinterpret_cast<const float *>(&(model.buffers[uvView.buffer].data[uvAccessor.byteOffset + uvView.byteOffset]));
                }
                
                auto descriptor = [[MDLVertexDescriptor alloc]init];
                descriptor.attributes[Attributes::Position] =
                [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributePosition
                                                 format:MDLVertexFormatFloat3
                                                 offset:0 bufferIndex:0];
                size_t offset = 12;
                size_t elementCount = 3;
                if (bufferNormals) {
                    descriptor.attributes[Attributes::Normal] =
                    [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeNormal
                                                     format:MDLVertexFormatFloat3
                                                     offset:offset bufferIndex:BufferIndexVertices];
                    offset += sizeof(float) * 3;
                    elementCount += 3;
                }
                
                if (bufferTexCoords) {
                    descriptor.attributes[Attributes::UV_0] =
                    [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTextureCoordinate
                                                     format:MDLVertexFormatFloat2
                                                     offset:offset bufferIndex:BufferIndexVertices];
                    offset += sizeof(float) * 2;
                    elementCount += 2;
                }
                
                if (bufferColors) {
                    descriptor.attributes[Attributes::Color_0] =
                    [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeColor
                                                     format:MDLVertexFormatFloat4
                                                     offset:offset bufferIndex:BufferIndexVertices];
                    offset += sizeof(float) * 4;
                    elementCount += 4;
                }
                
                if (bufferTangents) {
                    descriptor.attributes[Attributes::Tangent] =
                    [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTangent
                                                     format:MDLVertexFormatFloat4
                                                     offset:offset bufferIndex:BufferIndexVertices];
                    offset += sizeof(float) * 4;
                    elementCount += 4;
                }
                
                if (bufferJoints) {
                    descriptor.attributes[Attributes::Joints_0] =
                    [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeJointIndices
                                                     format:MDLVertexFormatFloat4
                                                     offset:offset bufferIndex:BufferIndexVertices];
                    offset += sizeof(float) * 4;
                    elementCount += 4;
                }
                
                if (bufferWeights) {
                    descriptor.attributes[Attributes::Weights_0] =
                    [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeJointWeights
                                                     format:MDLVertexFormatFloat4
                                                     offset:offset bufferIndex:BufferIndexVertices];
                    offset += sizeof(float) * 4;
                    elementCount += 4;
                }
                
                descriptor.layouts[0] = [[MDLVertexBufferLayout alloc]initWithStride:offset];
                newMesh->setVertexDescriptor(descriptor);

                std::vector<float> vertexBuffer;
                vertexBuffer.reserve(static_cast<uint32_t>(posAccessor.count) * elementCount);
                for (size_t v = 0; v < posAccessor.count; v++) {
                    vertexBuffer.insert(vertexBuffer.end(), &bufferPos[v * 3], &bufferPos[v * 3 + 3]);
                    if (bufferNormals) {
                        vertexBuffer.insert(vertexBuffer.end(), &bufferNormals[v * 3], &bufferNormals[v * 3 + 3]);
                    }
                    if (bufferTexCoords) {
                        vertexBuffer.insert(vertexBuffer.end(), &bufferTexCoords[v * 2], &bufferTexCoords[v * 2 + 2]);
                    }
                    if (bufferColors) {
                        switch (numColorComponents) {
                            case 3:
                                vertexBuffer.insert(vertexBuffer.end(), &bufferColors[v * 3], &bufferColors[v * 3 + 3]);
                                vertexBuffer.push_back(1.0);
                            case 4:
                                vertexBuffer.insert(vertexBuffer.end(), &bufferColors[v * 4], &bufferColors[v * 4 + 4]);
                            default:
                                std::cerr << "numColorComponents has problem" <<std::endl;
                        }
                    }
                    if (bufferTangents) {
                        vertexBuffer.insert(vertexBuffer.end(), &bufferTangents[v * 4], &bufferTangents[v * 4 + 4]);
                    }
                    if (bufferJoints) {
                        vertexBuffer.insert(vertexBuffer.end(), &bufferJoints[v * 4], &bufferJoints[v * 4 + 4]);
                    }
                    if (bufferWeights) {
                        vertexBuffer.insert(vertexBuffer.end(), &bufferWeights[v * 4], &bufferWeights[v * 4 + 4]);
                    }
                }
                auto vBuffer = [engine->_hardwareRenderer.device newBufferWithBytes:vertexBuffer.data()
                                                                             length:vertexBuffer.size() * sizeof(float) options:NULL];
                newMesh->setVertexBufferBinding(vBuffer, 0, 0);
            }
            // Indices
            {
                const tinygltf::Accessor &accessor = model.accessors[primitive.indices];
                const tinygltf::BufferView &bufferView = model.bufferViews[accessor.bufferView];
                const tinygltf::Buffer &buffer = model.buffers[bufferView.buffer];
                switch (accessor.componentType) {
                    case TINYGLTF_PARAMETER_TYPE_UNSIGNED_INT: {
                        std::vector<uint32_t> buf(accessor.count);
                        memcpy(buf.data(), &buffer.data[accessor.byteOffset + bufferView.byteOffset], accessor.count * sizeof(uint32_t));
                        auto iBuffer = [engine->_hardwareRenderer.device newBufferWithBytes:buf.data()
                                                                                     length:buf.size() * sizeof(uint32_t) options:NULL];
                        newMesh->addSubMesh(MeshBuffer(iBuffer,
                                                       buf.size() * sizeof(uint32_t),
                                                       MDLMeshBufferTypeIndex),
                                            MTLIndexTypeUInt32, buf.size(), MTLPrimitiveTypeTriangle);
                        break;
                    }
                    case TINYGLTF_PARAMETER_TYPE_UNSIGNED_SHORT: {
                        std::vector<uint16_t> buf(accessor.count);
                        memcpy(buf.data(), &buffer.data[accessor.byteOffset + bufferView.byteOffset], accessor.count * sizeof(uint16_t));
                        auto iBuffer = [engine->_hardwareRenderer.device newBufferWithBytes:buf.data()
                                                                                     length:buf.size() * sizeof(uint16_t) options:NULL];
                        newMesh->addSubMesh(MeshBuffer(iBuffer,
                                                       buf.size() * sizeof(uint16_t),
                                                       MDLMeshBufferTypeIndex),
                                            MTLIndexTypeUInt16, buf.size(), MTLPrimitiveTypeTriangle);
                        break;
                    }
                    case TINYGLTF_PARAMETER_TYPE_UNSIGNED_BYTE: {
                        std::vector<uint16_t> buf;
                        buf.reserve(accessor.count);
                        uint8_t *buf8 = new uint8_t[accessor.count];
                        memcpy(buf8, &buffer.data[accessor.byteOffset + bufferView.byteOffset], accessor.count * sizeof(uint8_t));
                        for (size_t index = 0; index < accessor.count; index++) {
                            buf.push_back(buf8[index]);
                        }
                        auto iBuffer = [engine->_hardwareRenderer.device newBufferWithBytes:buf.data()
                                                                                     length:buf.size() * sizeof(uint16_t) options:NULL];
                        newMesh->addSubMesh(MeshBuffer(iBuffer,
                                                       buf.size() * sizeof(uint16_t),
                                                       MDLMeshBufferTypeIndex),
                                            MTLIndexTypeUInt16, buf.size(), MTLPrimitiveTypeTriangle);
                        break;
                    }
                    default:
                        std::cerr << "Index component type " << accessor.componentType << " not supported!" << std::endl;
                        return;
                }
            }
            
            auto mat = primitive.material > -1 ? materials[primitive.material] : materials.back();
            renderer->setMaterial(j, mat);
        }
        renderer->setMesh(newMesh);
    }
}

void GLTFLoader::loadImages(tinygltf::Model& gltfModel, MetalRenderer* renderer) {
    for (tinygltf::Image &image : gltfModel.images) {
        textures.push_back(renderer->loadTexture(path, image.uri));
    }
}

void GLTFLoader::loadMaterials(tinygltf::Model& gltfModel) {
    for (tinygltf::Material &mat : gltfModel.materials) {
        auto material = std::make_shared<PBRMaterial>(engine);
        if (mat.values.find("baseColorTexture") != mat.values.end()) {
            material->setBaseTexture(textures[gltfModel.textures[mat.values["baseColorTexture"].TextureIndex()].source]);
        }
        // Metallic roughness workflow
        if (mat.values.find("metallicRoughnessTexture") != mat.values.end()) {
            material->setMetallicRoughnessTexture(textures[gltfModel.textures[mat.values["metallicRoughnessTexture"].TextureIndex()].source]);
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
            material->setNormalTexture(textures[gltfModel.textures[mat.additionalValues["normalTexture"].TextureIndex()].source]);
        }
        if (mat.additionalValues.find("emissiveTexture") != mat.additionalValues.end()) {
            material->setEmissiveTexture(textures[gltfModel.textures[mat.additionalValues["emissiveTexture"].TextureIndex()].source]);
        }
        if (mat.additionalValues.find("occlusionTexture") != mat.additionalValues.end()) {
            material->setOcclusionTexture(textures[gltfModel.textures[mat.additionalValues["occlusionTexture"].TextureIndex()].source]);
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
        GPUSkinnedMeshRenderer::SkinPtr newSkin = std::make_shared<GPUSkinnedMeshRenderer::Skin>();
        newSkin->name = source.name;
        
        // Find joint nodes
        for (int jointIndex : source.joints) {
            EntityPtr node = linearNodes[jointIndex].first;
            if (node) {
                newSkin->joints.push_back(node.get());
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

}
}
