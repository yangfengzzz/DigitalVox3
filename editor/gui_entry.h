//
//  gui_entry.hpp
//  editor
//
//  Created by 杨丰 on 2021/12/12.
//

#ifndef gizmo_hpp
#define gizmo_hpp

#include "../vox.render/runtime/script.h"
#include "../vox.render/gui/imgui.h"
#include "imgui_zmo.h"

namespace vox {
namespace picker {
class FramebufferPicker;
}
namespace control {
class OrbitControl;
}

namespace editor {
class GUIEntry : public Script {
public:
    GUIEntry(Entity *entity);
    
    void onUpdate(float deltaTime) override;
    
private:
    void editTransform(float *cameraView, float *cameraProjection, float *matrix, bool editTransformDecomposition);
    
private:
    Camera *camera = nullptr;
    picker::FramebufferPicker *picker = nullptr;
    control::OrbitControl *controller = nullptr;
    
    //selected
    Renderer *render = nullptr;
    
    //used for gui
    float fov;
    float camDistance = 8.f;
    ImGuizmo::OPERATION mCurrentGizmoOperation = ImGuizmo::TRANSLATE;
};

}
}

#endif /* gui_entry_hpp */
