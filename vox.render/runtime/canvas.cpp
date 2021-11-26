//
//  canvas.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "canvas.h"

static void glfw_error_callback(int error, const char* description)
{
    fprintf(stderr, "Glfw Error %d: %s\n", error, description);
}

namespace vox {
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
    
    _width = width;
    _height = height;
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

Float2 Canvas::scale() {
    glfwGetWindowContentScale(window, &_scale.x, &_scale.y);
    return _scale;
}

void Canvas::setScale(const Float2& value) {
}

void Canvas::resizeByClientSize(float pixelRatio) {
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
