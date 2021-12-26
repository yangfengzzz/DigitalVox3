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
class ModeIOLoader {
public:
    EntityPtr defaultSceneRoot;

    std::vector<id<MTLTexture>> textures;
    
    ModeIOLoader(Engine* engine);
    
    void loadFromFile(const std::string& path, const std::string& modelName);
    
private:
    void loadNode(EntityPtr parent, MDLObject* object);
    
private:
    Engine* engine;
};

}
}

#endif /* modelio_loader_hpp */
