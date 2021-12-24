//
//  render_pipeline.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_pipeline_hpp
#define render_pipeline_hpp

#include "maths/vec_float.h"
#include "../enums/textureCube_face.h"
#include "render_pass.h"
#include "render_context.h"
#include "../sky/sky.h"
#include "../lighting/light_manager.h"
#include "../lighting/light.h"
#include <optional>
#include <vector>

namespace vox {
using namespace math;

/**
 * Basic render pipeline.
 */
class RenderPipeline {
public:
    static constexpr int SHADOW_MAP_CASCADE_COUNT = 4;
    
    /**
     * Create a basic render pipeline.
     * @param camera - Camera
     */
    RenderPipeline(Camera* camera);
    
    /**
     * Destroy internal resources.
     */
    virtual ~RenderPipeline();
    
    /**
     * Perform scene rendering.
     * @param context - Render context
     * @param cubeFace - Render surface of cube texture
     * @param mipLevel - Set mip level the data want to write
     */
    void render(RenderContext& context,
                std::optional<TextureCubeFace> cubeFace = std::nullopt, int mipLevel = 0);
    
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
    
protected:
    virtual void _drawRenderPass(RenderPass* pass, Camera* camera,
                                 std::optional<TextureCubeFace> cubeFace = std::nullopt,
                                 int mipLevel = 0) = 0;
    
    void _drawShadowMap(RenderContext& context);
    
    void _drawCascadeShadowMap(RenderContext& context);
    
    /*
     * Calculate frustum split depths and matrices for the shadow map cascades
     * Based on https://johanmedestrom.wordpress.com/2016/03/18/opengl-cascaded-shadow-maps/
     */
    void _updateCascades(DirectLight* light);
    
    void _drawSky(const Sky& sky);
    
protected:
    static bool _compareFromNearToFar(const RenderElement& a, const RenderElement& b);
    static bool _compareFromFarToNear(const RenderElement& a, const RenderElement& b);
    std::vector<RenderElement> _opaqueQueue;
    std::vector<RenderElement> _transparentQueue;
    std::vector<RenderElement> _alphaTestQueue;
    
    Camera* _camera;
    
    float cascadeSplitLambda = 0.5f;
    const int shadowMapSize = 2000; // resolution
    uint32_t shadowCount = 0;
    std::array<ShadowData, LightManager::MAX_SHADOW> shadowDatas{};
    std::array<id<MTLTexture>, SHADOW_MAP_CASCADE_COUNT> cascadeShadowMaps{};
    std::vector<id<MTLTexture>> shadowMaps;
    id<MTLTexture> packedTexture{nullptr};
    
    /** Shader data. */
    ShaderData shaderData = ShaderData();
    static ShaderProperty _shadowMapProp;
    static ShaderProperty _shadowDataProp;
    
    RenderPass* _defaultPass;
    std::vector<std::unique_ptr<RenderPass>> _renderPassArray;
};

}


#endif /* render_pipeline_hpp */
