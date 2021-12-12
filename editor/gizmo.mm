//
//  gizmo.cpp
//  editor
//
//  Created by 杨丰 on 2021/12/12.
//

#include "gizmo.h"

#include "../vox.render/runtime/canvas.h"
#include "../vox.render/runtime/entity.h"
#include "../vox.render/runtime/camera.h"
#include "../vox.render/runtime/renderer.h"
#include "../vox.render/runtime/framebuffer_picker/framebuffer_picker.h"

namespace vox {
namespace editor {
Gizmo::Gizmo(Entity *entity) :
Script(entity) {
    camera = entity->getComponent<Camera>();
    fov = camera->fieldOfView();
    
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
}

void Gizmo::onUpdate(float deltaTime) {
    // Main loop
    ImGui::NewFrame();
    
    ImGuiIO &io = ImGui::GetIO();
    
    auto cameraProjection = camera->projectionMatrix();
    auto cameraView = camera->viewMatrix();
    
    ImGuizmo::SetOrthographic(camera->isOrthographic());
    ImGuizmo::BeginFrame();
    
    ImGui::SetNextWindowPos(ImVec2(1024, 100));
    ImGui::SetNextWindowSize(ImVec2(256, 256));
    
    // create a window and insert the inspector
    ImGui::SetNextWindowPos(ImVec2(10, 10));
    ImGui::SetNextWindowSize(ImVec2(320, 340));
    ImGui::Begin("Editor");
    
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
        auto modelMat = render->entity()->transform->localMatrix();
        editTransform(cameraView.elements.data(), cameraProjection.elements.data(),
                      modelMat.elements.data(), true);
        render->entity()->transform->setLocalMatrix(modelMat);
        cameraView = invert(cameraView);
        camera->entity()->transform->setWorldMatrix(cameraView);
    }
    
    ImGui::End();
    
    // Rendering
    ImGui::Render();
}

static const float identityMatrix[16] =
{1.f, 0.f, 0.f, 0.f,
    0.f, 1.f, 0.f, 0.f,
    0.f, 0.f, 1.f, 0.f,
    0.f, 0.f, 0.f, 1.f};

void Gizmo::editTransform(float *cameraView, float *cameraProjection, float *matrix, bool editTransformDecomposition) {
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
    
    ImGuizmo::DrawGrid(cameraView, cameraProjection, identityMatrix, 100.f);
    ImGuizmo::Manipulate(cameraView, cameraProjection, mCurrentGizmoOperation, mCurrentGizmoMode,
                         matrix, NULL, useSnap ? &snap[0] : NULL, boundSizing ? bounds : NULL, boundSizingSnap ? boundsSnap : NULL);
    
    ImGuizmo::ViewManipulate(cameraView, camDistance, ImVec2(viewManipulateRight - 128, viewManipulateTop), ImVec2(128, 128), 0x10101010);
}


}
}
