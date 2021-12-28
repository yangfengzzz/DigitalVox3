//
//  canvas.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef canvas_hpp
#define canvas_hpp

#define GLFW_INCLUDE_NONE
#define GLFW_EXPOSE_NATIVE_COCOA

#include <GLFW/glfw3.h>
#include <GLFW/glfw3native.h>
#include <vector>
#include "maths/vec_float.h"

namespace vox {
using namespace math;

/**
 * The canvas used on the web, which can support GLFW.
 */
class Canvas {
public:
    Canvas(int width, int height, const char *title);
    
    ~Canvas();
    
    int width() const;
    
    void setWidth(float value);
    
    int height() const;
    
    void setHeight(float value);
    
    bool isResized();
    
    void resetState();
    
    GLFWwindow *handle();
    
public:
    bool shouldClose();
    
    void processEvents();
    
    void close();
    
    float getDpiFactor() const;
    
    float getContentScaleFactor() const;
    
public:
    using CursorPosFunc = std::function<void(GLFWwindow *window, double xpos, double ypos)>;
    static std::vector<CursorPosFunc> cursor_callbacks;
    using MouseButtonFunc = std::function<void(GLFWwindow *window, int button, int action, int mods)>;
    static std::vector<MouseButtonFunc> mouse_button_callbacks;
    using ScrollFunc = std::function<void(GLFWwindow *window, double xoffset, double yoffset)>;
    static std::vector<ScrollFunc> scroll_callbacks;
    using KeyFunc = std::function<void(GLFWwindow *window, int key, int scancode, int action, int mods)>;
    static std::vector<KeyFunc> key_callbacks;
    using ResizeFunc = std::function<void(GLFWwindow *window, int width, int height)>;
    static std::vector<ResizeFunc> resize_callbacks;
    
private:
    static void cursorPosCallback(GLFWwindow *window, double xpos, double ypos);
    
    static void mouseButtonCallback(GLFWwindow *window, int button, int action, int mods);
    
    static void scrollCallback(GLFWwindow *window, double xoffset, double yoffset);
    
    static void keyCallback(GLFWwindow *window, int key, int scancode, int action, int mods);
    
    static void windowResizeCallback(GLFWwindow *window, int width, int height);
    
private:
    int _width;
    int _height;
    Float2 _scale = Float2();
    
    GLFWwindow *window;
};

}

#endif /* canvas_hpp */
