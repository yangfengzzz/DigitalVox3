//
//  grid.hpp
//  editor
//
//  Created by 杨丰 on 2021/12/12.
//

#ifndef grid_hpp
#define grid_hpp

#include "../vox.render/runtime/script.h"

namespace vox {
namespace editor {
class Grid : public Script {
public:
    Grid(Entity *entity);
        
private:
    ModelMeshPtr createPlane(Engine* engine);
    
private:
    MeshRenderer* _renderer;
    MaterialPtr _mtl;
};

}
}

#endif /* grid_hpp */
