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
#include "maths/vec_float.h"

namespace vox {
using namespace math;

/**
 * The canvas used on the web, which can support GLFW.
 */
class Canvas  {
public:
    Canvas(int width, int height, const char* title);
    
    int width() const;

    void setWidth(float value);
    
    int height() const;

    void setHeight(float value);
    
    /**
     * The scale of canvas, the value is visible width/height divide the render width/height.
     * @remarks Need to re-assign after modification to ensure that the modification takes effect.
     */
    Float2 scale();

    void setScale(const Float2& value);
    
    /**
     * Resize the rendering size according to the clientWidth and clientHeight of the canvas.
     * @param pixelRatio - Pixel ratio
     */
    void resizeByClientSize(float pixelRatio);
    
public:
    bool should_close();

    void process_events();

    void close();

    float get_dpi_factor() const;

    float get_content_scale_factor() const;
    
private:
    GLFWwindow* window;
    
    int _width;
    int _height;
    Float2 _scale = Float2();
};

}

#endif /* canvas_hpp */
