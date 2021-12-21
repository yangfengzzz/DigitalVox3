//
//  color_render_pass.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#ifndef color_render_pass_hpp
#define color_render_pass_hpp

#include "../render_pipeline/render_pass.h"
#include "color_material.h"

namespace vox {
namespace picker {
/**
 * Color render Pass, used to render marker.
 */
class ColorRenderPass :public RenderPass {
public:
    ColorRenderPass(const std::string& name, int priority, MTLRenderPassDescriptor* renderTarget, Layer mask, Engine* engine);
    
    void setPickFunctor(std::function<void(Renderer*, MeshPtr)> func);
    
public:
    MaterialPtr material(const RenderElement& element) override;
    
    /**
     * Determine whether need to render pass, reset state.
     */
    void preRender(Camera* camera, const std::vector<RenderElement>& opaqueQueue,
                   const std::vector<RenderElement>& alphaTestQueue,
                   const std::vector<RenderElement>& transparentQueue) override;
    
    void postRender(Camera* camera, const std::vector<RenderElement>& opaqueQueue,
                    const std::vector<RenderElement>& alphaTestQueue,
                    const std::vector<RenderElement>& transparentQueue) override;
    
    /**
     * Determine whether to pick up.
     */
    void execute(Camera* camera);
    
    /**
     * Pick up coordinate pixels.
     */
    void pick(const math::Float2& pos);
    
    /**
     * Get pixel color value from framebuffer.
     */
    std::array<uint8_t, 4> readColorFromRenderTarget(Camera* camera);
    
private:
    bool _needPick;
    std::function<void(Renderer*, MeshPtr)> _onPick;
    math::Float2 _pickPos;
    std::shared_ptr<ColorMaterial> _material;
};

}
}

#endif /* color_render_pass_hpp */
