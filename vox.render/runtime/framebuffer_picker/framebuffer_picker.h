//
//  framebuffer_picker.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#ifndef framebuffer_picker_hpp
#define framebuffer_picker_hpp

#include "../script.h"
#include "color_render_pass.h"

namespace vox {
namespace picker {
/**
 * Framebuffer picker.
 * @remarks Can pick up renderer at pixel level.
 */
class FramebufferPicker : public Script {
public:
    /**
     * Camera.
     */
    Camera *camera();
    
    void setCamera(Camera *value);
    
    FramebufferPicker(Entity *entity);
    
    /**
     * Set the callback function after pick up.
     * @param fun Callback function. if there is an renderer selected, the parameter 1 is {component, primitive }, otherwise it is undefined
     */
    void setPickFunctor(std::function<void(Renderer *, MeshPtr)> fun);
    
    /**
     * Pick the object at the screen coordinate position.
     * @param offsetX Relative X coordinate of the canvas
     * @param offsetY Relative Y coordinate of the canvas
     */
    void pick(float offsetX, float offsetY);
    
    void onUpdate(float deltaTime) override;
    
    void onEndFrame() override;
    
    void onDestroy() override;
    
private:
    MetalLoaderPtr metalResourceLoader;
    MTLRenderPassDescriptor *colorRenderTarget;
    ColorRenderPass *colorRenderPass;
    
    Camera *_camera;
    bool _needPick;
    math::Float2 _pickPos;
};

}
}

#endif /* framebuffer_picker_hpp */
