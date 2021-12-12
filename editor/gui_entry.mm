//
//  gui_entry.cpp
//  editor
//
//  Created by 杨丰 on 2021/12/12.
//

#include "gui_entry.h"
#include "../vox.render/gui/imgui.h"

namespace vox {
namespace editor {
GUIEntry::GUIEntry(Entity *entity) :
Script(entity) {
}

void GUIEntry::onUpdate(float deltaTime) {
    ImGui::NewFrame();
    
    {
        static int counter = 0;
        
        ImGui::Begin("Hello, world!");                          // Create a window called "Hello, world!" and append into it.
        
        ImGui::Text("This is some useful text.");               // Display some text (you can use a format strings too)
        
        if (ImGui::Button("Button"))                            // Buttons return true when clicked (most widgets return true when edited/activated)
            counter++;
        ImGui::SameLine();
        ImGui::Text("counter = %d", counter);
        
        ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
        ImGui::End();
    }
    
    // Rendering
    ImGui::Render();
}


}
}
