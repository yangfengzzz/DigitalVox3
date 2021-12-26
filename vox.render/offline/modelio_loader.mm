//
//  modelio_loader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/26.
//

#include "modelio_loader.h"
#include "../runtime/engine.h"
#include "../runtime/mesh/gpu_skinned_mesh_renderer.h"

namespace vox {
namespace offline {
ModeIOLoader::ModeIOLoader(Engine* engine):
engine(engine) {
    defaultSceneRoot = std::make_shared<Entity>(engine);
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

    // Have ModelIO create bitangents from mesh texture coordinates and the newly created tangents
    [modelIOMesh addTangentBasisForTextureCoordinateAttributeNamed:MDLVertexAttributeTextureCoordinate
                                             tangentAttributeNamed:MDLVertexAttributeTangent
                                           bitangentAttributeNamed:MDLVertexAttributeBitangent];
    
    // Create the metalKit mesh which will contain the Metal buffer(s) with the mesh's vertex data
    //   and submeshes with info to draw the mesh
    MTKMesh* metalKitMesh = engine->_hardwareRenderer.convertFrom(modelIOMesh);
    
    auto renderer = parent->addComponent<GPUSkinnedMeshRenderer>();
    
}

}
}
