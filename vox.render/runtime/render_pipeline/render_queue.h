//
//  render_queue.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_queue_hpp
#define render_queue_hpp

#include "../layer.h"
#include "render_element.h"
#include <vector>

namespace vox {
class Engine;
using EnginePtr = std::shared_ptr<Engine>;
class Camera;

/// Render queue.
class RenderQueue {
public:
    RenderQueue(EnginePtr engine);
    
    /// Push a render element.
    void pushPrimitive(RenderElement element);

    void render(Camera* camera, MaterialPtr replaceMaterial, Layer mask);
    
    /// Clear collection.
    void clear();

    /// Destroy internal resources.
    void destroy();

    /// Sort the elements.
    void sort(std::function<bool(const RenderElement&, const RenderElement&)> compareFunc);
    
private:
    std::vector<RenderElement> items;

    static bool _compareFromNearToFar(const RenderElement& a, const RenderElement& b);

    static bool _compareFromFarToNear(const RenderElement& a, const RenderElement& b);
};

}

#endif /* render_queue_hpp */
