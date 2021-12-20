//
//  render_pass.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_pass_hpp
#define render_pass_hpp

#include "../vox_type.h"
#include "../layer.h"
#include "../enums/camera_clear_flags.h"
#include "render_element.h"
#include "maths/color.h"
#include <Metal/Metal.h>
#include <string>
#include <optional>

namespace vox {
using namespace math;
/**
 * RenderPass.
 */
class RenderPass {
public:
    std::string name;
    bool enabled;
    int priority;
    MTLRenderPassDescriptor* renderTarget;
    Layer mask;
    bool renderOverride;
    std::optional<CameraClearFlags::Enum> clearFlags;
    std::optional<math::Color> clearColor;
    
    /**
     * Create a RenderPass.
     * @param name - Pass name
     * @param priority - Priority, less than 0 before the default pass, greater than 0 after the default pass
     * @param renderTarget - The specified Render Target
     * @param mask - Perform bit and operations with Entity.Layer to filter the objects that this Pass needs to render
     */
    RenderPass(const std::string& name = "",
               int priority = 0,
               MTLRenderPassDescriptor* renderTarget = nullptr,
               Layer mask = Layer::Everything);
    
    virtual MaterialPtr material(const RenderElement& element) { return nullptr; }
    
    /**
     * Rendering callback, will be executed if renderOverride is set to true.
     * @param camera - Camera
     * @param opaqueQueue - Opaque queue
     * @param alphaTestQueue - Alpha test queue
     * @param transparentQueue - Transparent queue
     */
    virtual void render(Camera* camera, const RenderQueue& opaqueQueue,
                        const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) {}
    
    /**
     * Post rendering callback.
     * @param camera - Camera
     * @param opaqueQueue - Opaque queue
     * @param alphaTestQueue - Alpha test queue
     * @param transparentQueue - Transparent queue
     */
    virtual void preRender(Camera* camera, const RenderQueue& opaqueQueue,
                           const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) {}
    
    /**
     * Post rendering callback.
     * @param camera - Camera
     * @param opaqueQueue - Opaque queue
     * @param alphaTestQueue - Alpha test queue
     * @param transparentQueue - Transparent queue
     */
    virtual void postRender(Camera* camera, const RenderQueue& opaqueQueue,
                            const RenderQueue& alphaTestQueue, const RenderQueue& transparentQueue) {}
    
private:
    static size_t passNum;
};

}

#endif /* render_pass_hpp */
