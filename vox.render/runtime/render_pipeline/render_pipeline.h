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
    
public:
    /**
     * Perform scene rendering.
     * @param context - Render context
     * @param cubeFace - Render surface of cube texture
     * @param mipLevel - Set mip level the data want to write
     */
    virtual void render(RenderContext& context,
                        std::optional<TextureCubeFace> cubeFace = std::nullopt, int mipLevel = 0) = 0;
    
protected:
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
};

}


#endif /* render_pipeline_hpp */
