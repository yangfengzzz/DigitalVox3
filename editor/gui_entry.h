//
//  gui_entry.hpp
//  editor
//
//  Created by 杨丰 on 2021/12/12.
//

#ifndef gui_entry_hpp
#define gui_entry_hpp

#include "../vox.render/runtime/script.h"

namespace vox {
namespace editor {
class GUIEntry:public Script {
public:
    GUIEntry(Entity* entity);
    
    void onUpdate(float deltaTime) override;
};

}
}

#endif /* gui_entry_hpp */
