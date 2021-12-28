//
//  debugger.hpp
//  editor
//
//  Created by 杨丰 on 2021/12/14.
//

#ifndef debugger_hpp
#define debugger_hpp

#include "editor_component.h"

namespace vox {
namespace editor {
class Debugger : public EditorComponent {
public:
    void onUpdate() override;
};

}
}

#endif /* debugger_hpp */
