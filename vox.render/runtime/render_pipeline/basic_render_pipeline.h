//
//  basic_render_pipeline.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef basic_render_pipeline_hpp
#define basic_render_pipeline_hpp

#include "maths/vec_float.h"
#include "../enums/textureCube_face.h"
#include "render_queue.h"
#include "render_pass.h"
#include "render_context.h"
#include <optional>

namespace vox {
using namespace math;

/**
 * Basic render pipeline.
 */
class BasicRenderPipeline {
public:
    /**
     * Create a basic render pipeline.
     * @param camera - Camera
     */
    BasicRenderPipeline(Camera* camera);
    
    /**
     * Destroy internal resources.
     */
    void destroy();
    
public:
    /**
     * Perform scene rendering.
     * @param context - Render context
     * @param cubeFace - Render surface of cube texture
     * @param mipLevel - Set mip level the data want to write
     */
    void render(const RenderContext& context, std::optional<TextureCubeFace> cubeFace = std::nullopt,
                int mipLevel = 0);
    
    /**
     * Push a render element to the render queue.
     * @param element - Render element
     */
    void pushPrimitive(const RenderElement& element);
        
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
    
private:
    friend class ShadowManager;
    RenderQueue _opaqueQueue;
    RenderQueue _transparentQueue;
    RenderQueue _alphaTestQueue;

    Camera* _camera;
    RenderPass* _defaultPass;
    std::vector<std::unique_ptr<RenderPass>> _renderPassArray;
    Float2 _lastCanvasSize = Float2();
};

}


#endif /* basic_render_pipeline_hpp */
