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

}
