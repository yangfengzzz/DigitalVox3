//
//  modelio_loader.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/26.
//

#ifndef modelio_loader_hpp
#define modelio_loader_hpp

#include "../runtime/vox_type.h"
#include <MetalKit/MetalKit.h>
#include <vector>
#include <string>

namespace vox {
namespace offline {
class ModelIOLoader {
public:
    EntityPtr defaultSceneRoot;

    std::vector<id<MTLTexture>> textures;
    std::vector<MaterialPtr> materials;
    
    ModelIOLoader(Engine* engine);
    
    void loadFromFile(const std::string& path, const std::string& modelName);
    
private:
    void loadNode(EntityPtr parent, MDLObject* object);
    
    void loadMesh(EntityPtr parent, MDLMesh* modelIOMesh);
    
    void loadMaterial(std::shared_ptr<BlinnPhongMaterial>& pbr, MDLMaterial* material);

    
private:
    Engine* engine;
    MetalLoaderPtr metalResourceLoader;
    
    // Vertex descriptor for models loaded with MetalKit
    MTLVertexDescriptor *_defaultVertexDescriptor;
    // Create a ModelIO vertexDescriptor so that the format/layout of the ModelIO mesh vertices
    //   cah be made to match Metal render pipeline's vertex descriptor layout
    MDLVertexDescriptor *_modelIOVertexDescriptor;
};

}
}

#endif /* modelio_loader_hpp */
