//
//  editor_component.hpp
//  editor
//
//  Created by 杨丰 on 2021/12/14.
//

#ifndef editor_component_hpp
#define editor_component_hpp

#include <stdio.h>

namespace vox {
namespace editor {
class EditorComponent {
public:
    virtual ~EditorComponent() {
    }
    
    virtual void onUpdate() = 0;
};

}
}

#endif /* editor_component_hpp */
