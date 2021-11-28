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

/// Basic render pipeline.
class BasicRenderPipeline {
public:
    /// Create a basic render pipeline.
    /// - Parameter camera: Camera
    BasicRenderPipeline(Camera* camera);
    
    /// Destroy internal resources.
    void destroy();
    
public:
    /// Perform scene rendering.
    /// - Parameters:
    ///   - context: Render context
    ///   - cubeFace: Render surface of cube texture
    void render(const RenderContext& context, std::optional<TextureCubeFace> cubeFace = std::nullopt,
                int mipLevel = 0);
    
    void _drawRenderPass(RenderPass& pass, Camera* camera,
                         std::optional<TextureCubeFace> cubeFace = std::nullopt,
                         int mipLevel = 0);
    
    /// Push a render element to the render queue.
    /// - Parameter element: Render element
    void pushPrimitive(const RenderElement& element);
    
    // void _drawSky(Engine* engine, Camera* camera, Sky sky);
    
public:
    /// Default render pass.
    RenderPass defaultRenderPass();
    
    /// Add render pass.
    /// - Parameters:
    ///   - pass: RenderPass object.
    void addRenderPass(const RenderPass& pass);
    
    /// Add render pass.
    /// - Parameters:
    ///   - name: The name of this Pass.
    ///   - priority: Priority, less than 0 before the default pass, greater than 0 after the default pass
    ///   - renderTarget: The specified Render Target
    ///   - replaceMaterial: Replaced material
    ///   - mask: Perform bit and operations with Entity.Layer to filter the objects that this Pass needs to render
    void addRenderPass(const std::string& name,
                       int priority = 0,
                       MTLRenderPassDescriptor* renderTarget = nullptr,
                       MaterialPtr replaceMaterial = nullptr,
                       Layer mask = Layer::Everything);
    
    /// Remove render pass by name or render pass object.
    /// - Parameter name: Render pass name
    void removeRenderPass(const std::string& name);
    
    /// Remove render pass by name or render pass object.
    /// - Parameter pass: render pass object
    void removeRenderPass(const RenderPass& pass);
    
    /// Get render pass by name.
    /// - Parameter name: Render pass name
    std::optional<RenderPass> getRenderPass(const std::string& name);
    
private:
    RenderQueue _opaqueQueue;
    RenderQueue _transparentQueue;
    RenderQueue _alphaTestQueue;

    Camera* _camera;
    RenderPass _defaultPass;
    std::vector<RenderPass> _renderPassArray;
    Float2 _lastCanvasSize = Float2();
};

}


#endif /* basic_render_pipeline_hpp */
