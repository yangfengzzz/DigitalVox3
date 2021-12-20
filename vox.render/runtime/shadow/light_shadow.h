//
//  light_shadow.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#ifndef light_shadow_hpp
#define light_shadow_hpp

#include "../vox_type.h"
#include "../shader/shader_property.h"
#include "../shader/shader_data.h"
#include "maths/matrix.h"
#include <array>

namespace vox {
/**
 * Shadow manager.
 */
class LightShadow {
public:
    /**
     * Shadow bias.
     */
    float bias = 0.005;

    /**
     * Shadow intensity, the larger the value, the clearer and darker the shadow.
     */
    float intensity = 0.2;

    /**
     * Pixel range used for shadow PCF interpolation.
     */
    float radius = 1;

    /**
     * Generate the projection matrix used by the shadow map.
     */
    math::Matrix projectionMatrix;
    
    /**
     * Clear all shadow maps.
     */
    static void clearMap();
    
    LightShadow(Light* light, Engine* engine, float width = 512, float height = 512);
    
    /**
     * The RenderTarget corresponding to the shadow map.
     */
    MTLRenderPassDescriptor* renderTarget();

    /**
     * Shadow map's color render texture.
     */
    id<MTLTexture> map();

    /**
     * Shadow map size.
     */
    math::Float2 mapSize();
    
    /**
     * Initialize the projection matrix for lighting.
     * @param light - The light to generate shadow
     */
    void initShadowProjectionMatrix(Light* light);
    
    void appendData(int lightIndex);
    
private:
    static constexpr int _maxLight = 3;
    static struct {
        std::array<math::Matrix, _maxLight> viewMatrix;
        std::array<math::Matrix, _maxLight> projectionMatrix;
        std::array<float, _maxLight> bias;
        std::array<float, _maxLight> intensity;
        std::array<float, _maxLight> radius;
        std::array<math::Float2, _maxLight> mapSize;
        std::array<id<MTLTexture>, _maxLight> map;
    } _combinedData;
    
    static ShaderProperty _viewMatFromLightProperty;
    static ShaderProperty _projMatFromLightProperty;
    static ShaderProperty _shadowBiasProperty;
    static ShaderProperty _shadowIntensityProperty;
    static ShaderProperty _shadowRadiusProperty;
    static ShaderProperty _shadowMapSizeProperty;
    static ShaderProperty _shadowMapsProperty;
    
    static void _updateShaderData(ShaderData& shaderData);
    
    math::Float2 _mapSize;
    MTLRenderPassDescriptor* _renderTarget;
    /**
     * Shadow's light.
     */
    Light* light;
};

}


#endif /* light_shadow_hpp */
