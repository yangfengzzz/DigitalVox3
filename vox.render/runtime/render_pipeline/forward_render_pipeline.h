//
//  render_pipeline.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/24.
//

#ifndef forward_render_pipeline_hpp
#define forward_render_pipeline_hpp

#include "render_pipeline.h"

namespace vox {
class ForwardRenderPipeline :public RenderPipeline {
public:
    ForwardRenderPipeline(Camera* camera);
    
    ~ForwardRenderPipeline();
    
    /**
     * Perform scene rendering.
     * @param context - Render context
     * @param cubeFace - Render surface of cube texture
     * @param mipLevel - Set mip level the data want to write
     */
    void render(RenderContext& context,
                std::optional<TextureCubeFace> cubeFace = std::nullopt, int mipLevel = 0) override;
    
public:
    /**
     * Default render pass.
     */
    RenderPass* defaultRenderPass();
    
    /**
     * Add render pass.
     * @param pass - The name of this Pass.
     */
    void addRenderPass(std::unique_ptr<RenderPass>&& pass);
    
    /**
     * Add render pass.
     * @param name - The name of this Pass or RenderPass object. When it is a name, the following parameters need to be provided
     * @param priority - Priority, less than 0 before the default pass, greater than 0 after the default pass
     * @param renderTarget - The specified Render Target
     * @param mask - Perform bit and operations with Entity.Layer to filter the objects that this Pass needs to render
     */
    void addRenderPass(const std::string& name,
                       int priority = 0,
                       MTLRenderPassDescriptor* renderTarget = nullptr,
                       Layer mask = Layer::Everything);
    
    /**
     * Remove render pass by name or render pass object.
     * @param name - Render pass name
     */
    void removeRenderPass(const std::string& name);
    
    /**
     * Remove render pass by name or render pass object.
     * @param pass - Render pass object
     */
    void removeRenderPass(const RenderPass* pass);
    
    /**
     * Get render pass by name.
     * @param  name - Render pass name
     */
    RenderPass* getRenderPass(const std::string& name);
    
private:
    void _drawRenderPass(RenderPass* pass, Camera* camera,
                         std::optional<TextureCubeFace> cubeFace = std::nullopt,
                         int mipLevel = 0);
    
    void _drawElement(const std::vector<RenderElement>& renderQueue, RenderPass* pass);
    
private:
    RenderPass* _defaultPass;
    std::vector<std::unique_ptr<RenderPass>> _renderPassArray;
};

}

#endif /* forward_render_pipeline_hpp */
