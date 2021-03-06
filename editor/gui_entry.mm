//
//  gui_entry.cpp
//  editor
//
//  Created by 杨丰 on 2021/12/12.
//

#include "gui_entry.h"

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/entity.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/renderer.h"
#include "../vox.render/runtime/framebuffer_picker/framebuffer_picker.h"
#include "../vox.render/runtime/controls/orbit_control.h"

namespace vox {
namespace editor {
GUIEntry::GUIEntry(Entity *entity) :
Script(entity) {
    camera = entity->getComponent<Camera>();
    fov = camera->fieldOfView();
    
    controller = entity->addComponent<control::OrbitControl>();
    
    picker = entity->addComponent<picker::FramebufferPicker>();
    picker->setCamera(camera);
    picker->setPickFunctor([&](Renderer *render, MeshPtr mesh) {
        if (render != nullptr) {
            this->render = render;
        }
    });
    
    Canvas::mouse_button_callbacks.push_back([&](GLFWwindow *window, int button, int action, int mods) {
        if (action == GLFW_PRESS) {
            double xpos, ypos;
            glfwGetCursorPos(window, &xpos, &ypos);
            picker->pick(xpos, ypos);
        }
    });
    
    NodeEditor::Config config;
    config.SettingsFile = "BasicInteraction.json";
    g_Context = NodeEditor::CreateEditor(&config);
}

GUIEntry::~GUIEntry() {
    _editorScripts.clear();
    NodeEditor::DestroyEditor(g_Context);
}

void GUIEntry::addEditorComponent(std::unique_ptr<EditorComponent> &&component) {
    _editorScripts.emplace_back(std::move(component));
}

void GUIEntry::removeEditorComponent(EditorComponent *component) {
    _editorScripts.erase(std::remove_if(_editorScripts.begin(), _editorScripts.end(),
                                        [&](const auto &script) {
        return script.get() == component;
    }), _editorScripts.end());
}

void GUIEntry::onUpdate(float deltaTime) {
    // Main loop
    ImGui::NewFrame();
    
    if (ImGui::IsAnyItemActive()) {
        controller->setEnabled(false);
    } else {
        controller->setEnabled(true);
    }
    
    ImGuiIO &io = ImGui::GetIO();
    
    auto cameraProjection = camera->projectionMatrix();
    auto cameraView = camera->viewMatrix();
    
    ImGuizmo::SetOrthographic(camera->isOrthographic());
    ImGuizmo::BeginFrame();
    
    if (showEditor) {
        controller->setEnabled(false);
        
        // Add padding around the text so that the options are not
        // too close to the edges and are easier to interact with.
        // Also add double vertical padding to avoid rounded corners.
        const float window_padding = ImGui::CalcTextSize("T").x;
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2{window_padding, window_padding * 2.0f});
        ImGui::SetNextWindowBgAlpha(0.0);
        ImGui::SetNextWindowSize(ImGui::GetIO().DisplaySize, ImGuiCond_Always);
        ImGui::SetNextWindowPos(ImVec2(0, 0), ImGuiCond_Always);
        const ImGuiWindowFlags flags = (ImGuiWindowFlags_NoMove |
                                        ImGuiWindowFlags_NoTitleBar |
                                        ImGuiWindowFlags_NoScrollbar |
                                        ImGuiWindowFlags_NoResize |
                                        ImGuiWindowFlags_AlwaysAutoResize |
                                        ImGuiWindowFlags_AlwaysUseWindowPadding |
                                        ImGuiWindowFlags_NoSavedSettings);
        bool is_open = true;
        ImGui::Begin("Options", &is_open, flags);
        
        nodeEditor();
        
        ImGui::End();
        ImGui::PopStyleVar();
    } else {
        ImGui::SetNextWindowPos(ImVec2(10, 10));
        ImGui::SetNextWindowSize(ImVec2(350, ImGui::GetIO().DisplaySize.y - 20), ImGuiCond_Always);
        
        ImGui::Begin("Editor");
        
        ImGui::Checkbox("Open Node Editor", &showEditor);
        
        ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
        ImGui::Separator();
        
        ImGui::Text("Camera");
        ImGui::SliderFloat("Fov", &fov, 20.f, 110.f);
        camera->setFieldOfView(fov);
        
        ImGui::Text("X: %f Y: %f", io.MousePos.x, io.MousePos.y);
        if (ImGuizmo::IsUsing()) {
            ImGui::Text("Using gizmo");
        } else {
            ImGui::Text(ImGuizmo::IsOver() ? "Over gizmo" : "");
            ImGui::SameLine();
            ImGui::Text(ImGuizmo::IsOver(ImGuizmo::TRANSLATE) ? "Over translate gizmo" : "");
            ImGui::SameLine();
            ImGui::Text(ImGuizmo::IsOver(ImGuizmo::ROTATE) ? "Over rotate gizmo" : "");
            ImGui::SameLine();
            ImGui::Text(ImGuizmo::IsOver(ImGuizmo::SCALE) ? "Over scale gizmo" : "");
        }
        ImGui::Separator();
        
        if (render != nullptr) {
            if (ImGuizmo::IsOver()) {
                controller->setEnabled(false);
            }
            
            auto modelMat = render->entity()->transform->localMatrix();
            editTransform(cameraView.elements.data(), cameraProjection.elements.data(),
                          modelMat.elements.data(), true);
            render->entity()->transform->setLocalMatrix(modelMat);
            cameraView = invert(cameraView);
            camera->entity()->transform->setWorldMatrix(cameraView);
        }
        
        for (auto &component: _editorScripts) {
            component->onUpdate();
        }
        
        ImGui::End();
    }
    
    // Rendering
    ImGui::Render();
}

void GUIEntry::editTransform(float *cameraView, float *cameraProjection, float *matrix, bool editTransformDecomposition) {
    static ImGuizmo::MODE mCurrentGizmoMode(ImGuizmo::LOCAL);
    static bool useSnap = false;
    static float snap[3] = {1.f, 1.f, 1.f};
    static float bounds[] = {-0.5f, -0.5f, -0.5f, 0.5f, 0.5f, 0.5f};
    static float boundsSnap[] = {0.1f, 0.1f, 0.1f};
    static bool boundSizing = false;
    static bool boundSizingSnap = false;
    
    if (editTransformDecomposition) {
        if (ImGui::IsKeyPressed(90))
            mCurrentGizmoOperation = ImGuizmo::TRANSLATE;
        if (ImGui::IsKeyPressed(69))
            mCurrentGizmoOperation = ImGuizmo::ROTATE;
        if (ImGui::IsKeyPressed(82)) // r Key
            mCurrentGizmoOperation = ImGuizmo::SCALE;
        if (ImGui::RadioButton("Translate", mCurrentGizmoOperation == ImGuizmo::TRANSLATE))
            mCurrentGizmoOperation = ImGuizmo::TRANSLATE;
        ImGui::SameLine();
        if (ImGui::RadioButton("Rotate", mCurrentGizmoOperation == ImGuizmo::ROTATE))
            mCurrentGizmoOperation = ImGuizmo::ROTATE;
        ImGui::SameLine();
        if (ImGui::RadioButton("Scale", mCurrentGizmoOperation == ImGuizmo::SCALE))
            mCurrentGizmoOperation = ImGuizmo::SCALE;
        if (ImGui::RadioButton("Universal", mCurrentGizmoOperation == ImGuizmo::UNIVERSAL))
            mCurrentGizmoOperation = ImGuizmo::UNIVERSAL;
        float matrixTranslation[3], matrixRotation[3], matrixScale[3];
        ImGuizmo::DecomposeMatrixToComponents(matrix, matrixTranslation, matrixRotation, matrixScale);
        ImGui::InputFloat3("Tr", matrixTranslation);
        ImGui::InputFloat3("Rt", matrixRotation);
        ImGui::InputFloat3("Sc", matrixScale);
        ImGuizmo::RecomposeMatrixFromComponents(matrixTranslation, matrixRotation, matrixScale, matrix);
        
        if (mCurrentGizmoOperation != ImGuizmo::SCALE) {
            if (ImGui::RadioButton("Local", mCurrentGizmoMode == ImGuizmo::LOCAL))
                mCurrentGizmoMode = ImGuizmo::LOCAL;
            ImGui::SameLine();
            if (ImGui::RadioButton("World", mCurrentGizmoMode == ImGuizmo::WORLD))
                mCurrentGizmoMode = ImGuizmo::WORLD;
        }
        if (ImGui::IsKeyPressed(83))
            useSnap = !useSnap;
        ImGui::Checkbox("", &useSnap);
        ImGui::SameLine();
        
        switch (mCurrentGizmoOperation) {
            case ImGuizmo::TRANSLATE:
                ImGui::InputFloat3("Snap", &snap[0]);
                break;
            case ImGuizmo::ROTATE:
                ImGui::InputFloat("Angle Snap", &snap[0]);
                break;
            case ImGuizmo::SCALE:
                ImGui::InputFloat("Scale Snap", &snap[0]);
                break;
            default:
                break;
        }
        ImGui::Checkbox("Bound Sizing", &boundSizing);
        if (boundSizing) {
            ImGui::PushID(3);
            ImGui::Checkbox("", &boundSizingSnap);
            ImGui::SameLine();
            ImGui::InputFloat3("Snap", boundsSnap);
            ImGui::PopID();
        }
    }
    
    ImGuiIO &io = ImGui::GetIO();
    float viewManipulateRight = io.DisplaySize.x;
    float viewManipulateTop = 0;
    ImGuizmo::SetRect(0, 0, io.DisplaySize.x, io.DisplaySize.y);
    
    ImGuizmo::Manipulate(cameraView, cameraProjection, mCurrentGizmoOperation, mCurrentGizmoMode,
                         matrix, NULL, useSnap ? &snap[0] : NULL, boundSizing ? bounds : NULL, boundSizingSnap ? boundsSnap : NULL);
    
    ImGuizmo::ViewManipulate(cameraView, camDistance, ImVec2(viewManipulateRight - 128, viewManipulateTop), ImVec2(128, 128), 0x10101010);
}

void GUIEntry::imGuiEx_BeginColumn() {
    ImGui::BeginGroup();
}

void GUIEntry::imGuiEx_NextColumn() {
    ImGui::EndGroup();
    ImGui::SameLine();
    ImGui::BeginGroup();
}

void GUIEntry::imGuiEx_EndColumn() {
    ImGui::EndGroup();
}

void GUIEntry::nodeEditor() {
    ImGui::Checkbox("Close Node Editor", &showEditor);
    
    ImGui::Separator();
    
    NodeEditor::SetCurrentEditor(g_Context);
    
    // Start interaction with editor.
    NodeEditor::Begin("My Editor", ImVec2(0.0, 0.0f));
    
    int uniqueId = 1;
    
    //
    // 1) Commit known data to editor
    //
    
    // Submit Node A
    NodeEditor::NodeId nodeA_Id = uniqueId++;
    NodeEditor::PinId nodeA_InputPinId = uniqueId++;
    NodeEditor::PinId nodeA_OutputPinId = uniqueId++;
    
    if (g_FirstFrame)
        NodeEditor::SetNodePosition(nodeA_Id, ImVec2(10, 10));
    NodeEditor::BeginNode(nodeA_Id);
    ImGui::Text("Node A");
    NodeEditor::BeginPin(nodeA_InputPinId, NodeEditor::PinKind::Input);
    ImGui::Text("-> In");
    NodeEditor::EndPin();
    ImGui::SameLine();
    NodeEditor::BeginPin(nodeA_OutputPinId, NodeEditor::PinKind::Output);
    ImGui::Text("Out ->");
    NodeEditor::EndPin();
    NodeEditor::EndNode();
    
    // Submit Node B
    NodeEditor::NodeId nodeB_Id = uniqueId++;
    NodeEditor::PinId nodeB_InputPinId1 = uniqueId++;
    NodeEditor::PinId nodeB_InputPinId2 = uniqueId++;
    NodeEditor::PinId nodeB_OutputPinId = uniqueId++;
    
    if (g_FirstFrame)
        NodeEditor::SetNodePosition(nodeB_Id, ImVec2(210, 60));
    NodeEditor::BeginNode(nodeB_Id);
    ImGui::Text("Node B");
    imGuiEx_BeginColumn();
    NodeEditor::BeginPin(nodeB_InputPinId1, NodeEditor::PinKind::Input);
    ImGui::Text("-> In1");
    NodeEditor::EndPin();
    NodeEditor::BeginPin(nodeB_InputPinId2, NodeEditor::PinKind::Input);
    ImGui::Text("-> In2");
    NodeEditor::EndPin();
    imGuiEx_NextColumn();
    NodeEditor::BeginPin(nodeB_OutputPinId, NodeEditor::PinKind::Output);
    ImGui::Text("Out ->");
    NodeEditor::EndPin();
    imGuiEx_EndColumn();
    NodeEditor::EndNode();
    
    // Submit Links
    for (auto &linkInfo: g_Links)
        NodeEditor::Link(linkInfo.Id, linkInfo.InputId, linkInfo.OutputId);
    
    //
    // 2) Handle interactions
    //
    
    // Handle creation action, returns true if editor want to create new object (node or link)
    if (NodeEditor::BeginCreate()) {
        NodeEditor::PinId inputPinId, outputPinId;
        if (NodeEditor::QueryNewLink(&inputPinId, &outputPinId)) {
            // QueryNewLink returns true if editor want to create new link between pins.
            //
            // Link can be created only for two valid pins, it is up to you to
            // validate if connection make sense. Editor is happy to make any.
            //
            // Link always goes from input to output. User may choose to drag
            // link from output pin or input pin. This determine which pin ids
            // are valid and which are not:
            //   * input valid, output invalid - user started to drag new ling from input pin
            //   * input invalid, output valid - user started to drag new ling from output pin
            //   * input valid, output valid   - user dragged link over other pin, can be validated
            
            if (inputPinId && outputPinId) // both are valid, let's accept link
            {
                // NodeEditor::AcceptNewItem() return true when user release mouse button.
                if (NodeEditor::AcceptNewItem()) {
                    // Since we accepted new link, lets add one to our list of links.
                    g_Links.push_back({NodeEditor::LinkId(g_NextLinkId++), inputPinId, outputPinId});
                    
                    // Draw new link.
                    NodeEditor::Link(g_Links.back().Id, g_Links.back().InputId, g_Links.back().OutputId);
                }
                
                // You may choose to reject connection between these nodes
                // by calling NodeEditor::RejectNewItem(). This will allow editor to give
                // visual feedback by changing link thickness and color.
            }
        }
    }
    NodeEditor::EndCreate(); // Wraps up object creation action handling.
    
    
    // Handle deletion action
    if (NodeEditor::BeginDelete()) {
        // There may be many links marked for deletion, let's loop over them.
        NodeEditor::LinkId deletedLinkId;
        while (NodeEditor::QueryDeletedLink(&deletedLinkId)) {
            // If you agree that link can be deleted, accept deletion.
            if (NodeEditor::AcceptDeletedItem()) {
                // Then remove link from your data.
                for (auto &link: g_Links) {
                    if (link.Id == deletedLinkId) {
                        g_Links.erase(&link);
                        break;
                    }
                }
            }
            
            // You may reject link deletion by calling:
            // NodeEditor::RejectDeletedItem();
        }
    }
    NodeEditor::EndDelete(); // Wrap up deletion action
    
    
    
    // End of interaction with editor.
    NodeEditor::End();
    
    if (g_FirstFrame)
        NodeEditor::NavigateToContent(0.0f);
    
    NodeEditor::SetCurrentEditor(nullptr);
    
    g_FirstFrame = false;
    
}


}
}
