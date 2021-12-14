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
#include "imgui_node_editor.h"
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
    
    ~GUIEntry();
    
    void onUpdate(float deltaTime) override;
    
    void addEditorComponent(std::unique_ptr<EditorComponent>&& component);
    
    void removeEditorComponent(EditorComponent* component);
    
private:
    void editTransform(float *cameraView, float *cameraProjection, float *matrix, bool editTransformDecomposition);
    
private:
    void imGuiEx_BeginColumn();

    void imGuiEx_NextColumn();

    void imGuiEx_EndColumn();
    
    void nodeEditor();
    
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
    bool showEditor = false;
    
    // Struct to hold basic information about connection between
    // pins. Note that connection (aka. link) has its own ID.
    // This is useful later with dealing with selections, deletion
    // or other operations.
    struct LinkInfo
    {
        NodeEditor::LinkId Id;
        NodeEditor::PinId  InputId;
        NodeEditor::PinId  OutputId;
    };

    NodeEditor::EditorContext*   g_Context = nullptr;    // Editor context, required to trace a editor state.
    bool                 g_FirstFrame = true;    // Flag set for first frame only, some action need to be executed once.
    ImVector<LinkInfo>   g_Links;                // List of live links. It is dynamic unless you want to create read-only view over nodes.
    int                  g_NextLinkId = 100;     // Counter to help generate link ids. In real application this will probably based on pointer to user data structure.
    
private:
    std::vector<std::unique_ptr<EditorComponent>> _editorScripts;
};

}
}

#endif /* gui_entry_hpp */
