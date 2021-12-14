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
#include "editor_component.h"
#include "imgui_zmo.h"
#include <vector>

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
    
    void addEditorComponent(std::unique_ptr<EditorComponent>&& component);
    
    void removeEditorComponent(EditorComponent* component);
    
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
    
private:
    std::vector<std::unique_ptr<EditorComponent>> _editorScripts;
};

}
}

#endif /* gui_entry_hpp */
