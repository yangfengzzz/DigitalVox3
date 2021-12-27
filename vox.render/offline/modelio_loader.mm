//
//  modelio_loader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/26.
//

#include "modelio_loader.h"
#include "../runtime/engine.h"
#include "../runtime/mesh/buffer_mesh.h"
#include "../runtime/mesh/gpu_skinned_mesh_renderer.h"
#include "../runtime/material/blinn_phong_material.h"

namespace vox {
namespace offline {
ModeIOLoader::ModeIOLoader(Engine* engine):
engine(engine),
metalResourceLoader(engine->resourceLoader()) {
    defaultSceneRoot = std::make_shared<Entity>(engine);
    
    _defaultVertexDescriptor = [MTLVertexDescriptor new];

    // Positions.
    _defaultVertexDescriptor.attributes[Attributes::Position].format = MTLVertexFormatFloat3;
    _defaultVertexDescriptor.attributes[Attributes::Position].offset = 0;
    _defaultVertexDescriptor.attributes[Attributes::Position].bufferIndex = 0;

    // Normals.
    _defaultVertexDescriptor.attributes[Attributes::Normal].format = MTLVertexFormatFloat3;
    _defaultVertexDescriptor.attributes[Attributes::Normal].offset = 0;
    _defaultVertexDescriptor.attributes[Attributes::Normal].bufferIndex = 1;
    
    // Tangents
    _defaultVertexDescriptor.attributes[Attributes::Tangent].format = MTLVertexFormatFloat4;
    _defaultVertexDescriptor.attributes[Attributes::Tangent].offset = 12;
    _defaultVertexDescriptor.attributes[Attributes::Tangent].bufferIndex = 1;
    
    // Texture coordinates.
    _defaultVertexDescriptor.attributes[Attributes::UV_0].format = MTLVertexFormatFloat2;
    _defaultVertexDescriptor.attributes[Attributes::UV_0].offset = 28;
    _defaultVertexDescriptor.attributes[Attributes::UV_0].bufferIndex = 1;

    // Position Buffer Layout
    _defaultVertexDescriptor.layouts[0].stride = 12;
    _defaultVertexDescriptor.layouts[0].stepRate = 1;
    _defaultVertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;

    // Generic Attribute Buffer Layout
    _defaultVertexDescriptor.layouts[1].stride = 36;
    _defaultVertexDescriptor.layouts[1].stepRate = 1;
    _defaultVertexDescriptor.layouts[1].stepFunction = MTLVertexStepFunctionPerVertex;
    
    // Create a ModelIO vertexDescriptor so that the format/layout of the ModelIO mesh vertices
    //   cah be made to match Metal render pipeline's vertex descriptor layout
    _modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(_defaultVertexDescriptor);

    // Indicate how each Metal vertex descriptor attribute maps to each ModelIO attribute
    _modelIOVertexDescriptor.attributes[Attributes::Position].name = MDLVertexAttributePosition;
    _modelIOVertexDescriptor.attributes[Attributes::Normal].name = MDLVertexAttributeNormal;
    _modelIOVertexDescriptor.attributes[Attributes::Tangent].name = MDLVertexAttributeTangent;
    _modelIOVertexDescriptor.attributes[Attributes::UV_0].name = MDLVertexAttributeTextureCoordinate;
}

void ModeIOLoader::loadFromFile(const std::string& path, const std::string& modelName) {
    NSString* pathName = [[NSString alloc]initWithUTF8String:path.c_str()];
    NSString* textureName = [[NSString alloc]initWithUTF8String:modelName.c_str()];
    NSURL* url = [[NSBundle bundleWithPath:pathName]URLForResource:textureName withExtension:nil];
    
    
    // Create a MetalKit mesh buffer allocator so that ModelIO will load mesh data directly into
    // Metal buffers accessible by the GPU
    MTKMeshBufferAllocator *bufferAllocator = engine->_hardwareRenderer.createBufferAllocator();

    // Use ModelIO to load the model file at the URL.  This returns a ModelIO asset object, which
    // contains a hierarchy of ModelIO objects composing a "scene" described by the model file.
    // This hierarchy may include lights, cameras, but, most importantly, mesh and submesh data
    // rendered with Metal
    MDLAsset *asset = [[MDLAsset alloc] initWithURL:url
                                   vertexDescriptor:nil
                                    bufferAllocator:bufferAllocator];
    if (!asset) {
        std::cerr << "Failed to open model file with given URL: " << url.absoluteString << std::endl;
    }

    // Traverse the ModelIO asset hierarchy to find ModelIO meshes and create app-specific
    // AAPLMesh objects from those ModelIO meshes
    for(MDLObject* object in asset) {
        loadNode(defaultSceneRoot, object);
    }
}

void ModeIOLoader::loadNode(EntityPtr parent, MDLObject* object) {
    auto entity = parent->createChild();
    
    // If this Model I/O  object is a mesh object (not a camera, light, or something else),
    // create an app-specific AAPLMesh object from it
    if ([object isKindOfClass:[MDLMesh class]]) {
        MDLMesh* mesh = (MDLMesh*) object;
        loadMesh(entity, mesh);
    }
    
    // Recursively traverse the ModelIO asset hierarchy to find ModelIO meshes that are children
    // of this ModelIO object and create app-specific AAPLMesh objects from those ModelIO meshes
    for (MDLObject *child in object.children) {
        loadNode(entity, child);
    }
}

void ModeIOLoader::loadMesh(EntityPtr parent, MDLMesh* modelIOMesh) {
    // Have ModelIO create the tangents from mesh texture coordinates and normals
    [modelIOMesh addTangentBasisForTextureCoordinateAttributeNamed:MDLVertexAttributeTextureCoordinate
                                              normalAttributeNamed:MDLVertexAttributeNormal
                                             tangentAttributeNamed:MDLVertexAttributeTangent];
    
    // Apply the ModelIO vertex descriptor that the renderer created to match the Metal vertex descriptor.

    // Assigning a new vertex descriptor to a ModelIO mesh performs a re-layout of the vertex
    // vertex data.  In this case, rthe renderer created the ModelIO vertex descriptor so that the
    // layout of the vertices in the ModelIO mesh match the layout of vertices the Metal render
    // pipeline expects as input into its vertex shader

    // Note ModelIO must create tangents and bitangents (as done above) before this relayout occur
    // This is because Model IO's addTangentBasis methods only works with vertex data is all in
    // 32-bit floating-point.  The vertex descriptor applied, changes those floats into 16-bit
    // floats or other types from which ModelIO cannot produce tangents

    modelIOMesh.vertexDescriptor = _modelIOVertexDescriptor;
    
    // Create the metalKit mesh which will contain the Metal buffer(s) with the mesh's vertex data
    //   and submeshes with info to draw the mesh
    MTKMesh* metalKitMesh = engine->_hardwareRenderer.convertFrom(modelIOMesh);
    
    auto renderer = parent->addComponent<GPUSkinnedMeshRenderer>();
    auto newMesh = std::make_shared<BufferMesh>(engine);
    newMesh->setVertexDescriptor(modelIOMesh.vertexDescriptor);
    for (int i = 0; i < metalKitMesh.vertexBuffers.count; i++) {
        newMesh->setVertexBufferBinding(metalKitMesh.vertexBuffers[i].buffer, 0, i);
    }
    
    for (int i = 0; i < metalKitMesh.submeshes.count; i++) {
        const auto& mtkSubmesh = metalKitMesh.submeshes[i];
        newMesh->addSubMesh(MeshBuffer(mtkSubmesh.indexBuffer.buffer, mtkSubmesh.indexBuffer.length, mtkSubmesh.indexBuffer.type),
                            mtkSubmesh.indexType, mtkSubmesh.indexCount, mtkSubmesh.primitiveType);
        
        auto mat = std::make_shared<BlinnPhongMaterial>(engine);
        loadMaterial(mat, modelIOMesh.submeshes[i].material);
        materials.push_back(mat);
        renderer->setMaterial(i, mat);
    }
    renderer->setMesh(newMesh);
}

void ModeIOLoader::loadMaterial(std::shared_ptr<BlinnPhongMaterial>& pbr, MDLMaterial* material) {
    pbr->setBaseTexture(metalResourceLoader->loadTexture(material, MDLMaterialSemanticBaseColor));
    pbr->setSpecularTexture(metalResourceLoader->loadTexture(material, MDLMaterialSemanticSpecular));
    pbr->setNormalTexture(metalResourceLoader->loadTexture(material, MDLMaterialSemanticTangentSpaceNormal));
}

}
}
