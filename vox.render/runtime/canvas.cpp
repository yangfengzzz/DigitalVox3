//
//  canvas.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "canvas.h"
#include "../gui/imgui_impl_glfw.h"

static void glfw_error_callback(int error, const char* description)
{
    fprintf(stderr, "Glfw Error %d: %s\n", error, description);
}

namespace vox {
std::vector<Canvas::CursorPosFunc> Canvas::cursor_callbacks = {};
void Canvas::cursorPosCallback(GLFWwindow* window, double xpos, double ypos) {
    for (auto& callback : cursor_callbacks) {
        callback(window, xpos, ypos);
    }
}

std::vector<Canvas::MouseButtonFunc> Canvas::mouse_button_callbacks = {};
void Canvas::mouseButtonCallback(GLFWwindow* window, int button, int action, int mods) {
    for (auto& callback : mouse_button_callbacks) {
        callback(window, button, action, mods);
    }
}

std::vector<Canvas::ScrollFunc> Canvas::scroll_callbacks = {};
void Canvas::scrollCallback(GLFWwindow* window, double xoffset, double yoffset) {
    for (auto& callback : scroll_callbacks) {
        callback(window, xoffset, yoffset);
    }
}

std::vector<Canvas::KeyFunc> Canvas::key_callbacks = {};
void Canvas::keyCallback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    for (auto& callback : key_callbacks) {
        callback(window, key, scancode, action, mods);
    }
}

std::vector<Canvas::ResizeFunc> Canvas::resize_callbacks = {};
void Canvas::windowResizeCallback(GLFWwindow* window, int width, int height) {
    for (auto& callback : resize_callbacks) {
        callback(window, width, height);
    }
}

Canvas::Canvas(int width, int height, const char* title) {
    // Setup window
    glfwSetErrorCallback(glfw_error_callback);
    if (!glfwInit())
        return;
    
    // Create window with graphics context
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    window = glfwCreateWindow(width, height, title, NULL, NULL);
    if (window == NULL)
        return;
    
    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    // Setup style
    ImGui::StyleColorsDark();
    
    glfwSetCursorPosCallback(window, cursorPosCallback);
    glfwSetMouseButtonCallback(window, mouseButtonCallback);
    glfwSetScrollCallback(window, scrollCallback);
    glfwSetKeyCallback(window, keyCallback);
    
    resize_callbacks.push_back([&](GLFWwindow* window, int width, int height){
        _width = width;
        _height = height;
    });
    glfwSetWindowSizeCallback(window, windowResizeCallback);
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    
    _width = width;
    _height = height;
}

Canvas::~Canvas() {
    cursor_callbacks.clear();
    mouse_button_callbacks.clear();
    scroll_callbacks.clear();
    key_callbacks.clear();
    
    glfwDestroyWindow(window);
    glfwTerminate();
}

int Canvas::width() const {
    return _width;
}

void Canvas::setWidth(float value) {
    _width = value;
    glfwSetWindowSize(window, _width, _height);
}

int Canvas::height() const {
    return _height;
}

void Canvas::setHeight(float value) {
    _height = value;
    glfwSetWindowSize(window, _width, _height);
}

GLFWwindow* Canvas::handle() {
    return window;
}

bool Canvas::shouldClose() {
    return glfwWindowShouldClose(window);
}

void Canvas::processEvents() {
    glfwPollEvents();
}

void Canvas::close() {
    glfwSetWindowShouldClose(window, GLFW_TRUE);
}

float Canvas::getDpiFactor() const {
    auto primary_monitor = glfwGetPrimaryMonitor();
    auto vidmode         = glfwGetVideoMode(primary_monitor);
    
    int width_mm, height_mm;
    glfwGetMonitorPhysicalSize(primary_monitor, &width_mm, &height_mm);
    
    // As suggested by the GLFW monitor guide
    static const float inch_to_mm       = 25.0f;
    static const float win_base_density = 96.0f;
    
    auto dpi        = static_cast<uint32_t>(vidmode->width / (width_mm / inch_to_mm));
    auto dpi_factor = dpi / win_base_density;
    return dpi_factor;
}

float Canvas::getContentScaleFactor() const {
    int fb_width, fb_height;
    glfwGetFramebufferSize(window, &fb_width, &fb_height);
    int win_width, win_height;
    glfwGetWindowSize(window, &win_width, &win_height);
    
    // We could return a 2D result here instead of a scalar,
    // but non-uniform scaling is very unlikely, and would
    // require significantly more changes in the IMGUI integration
    return static_cast<float>(fb_width) / win_width;
}

}
