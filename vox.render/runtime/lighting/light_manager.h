//
//  light_manager.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/6.
//

#ifndef light_manager_hpp
#define light_manager_hpp

#include "../vox_type.h"
#include "../shader/shader_data.h"
#include <vector>

namespace vox {
/**
 * Light Manager.
 */
class LightManager {
public:
    static constexpr uint32_t MAX_SHADOW = 10;
    static constexpr uint32_t MAX_CUBE_SHADOW = 5;

    LightManager();
    
    /**
     * Register a light object to the current scene.
     * @param light render light
     */
    void attachPointLight(PointLight* light);

    /**
     * Remove a light object from the current scene.
     * @param light render light
     */
    void detachPointLight(PointLight* light);
    
    const std::vector<PointLight*>& pointLights() const;
    
public:
    /**
     * Register a light object to the current scene.
     * @param light render light
     */
    void attachSpotLight(SpotLight* light);

    /**
     * Remove a light object from the current scene.
     * @param light render light
     */
    void detachSpotLight(SpotLight* light);
    
    const std::vector<SpotLight*>& spotLights() const;
    
public:
    /**
     * Register a light object to the current scene.
     * @param light direct light
     */
    void attachDirectLight(DirectLight* light);

    /**
     * Remove a light object from the current scene.
     * @param light direct light
     */
    void detachDirectLight(DirectLight* light);
    
    const std::vector<DirectLight*>& directLights() const;

private:
    friend class Scene;
    
    void _updateShaderData(ShaderData& shaderData);

    std::vector<PointLight*> _pointLights;
    std::vector<SpotLight*> _spotLights;
    std::vector<DirectLight*> _directLights;
};

}

#endif /* light_manager_hpp */
