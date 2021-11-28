//
//  render_queue.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "render_queue.h"
#include "../material/material.h"
#include "../renderer.h"

namespace vox {
RenderQueue::RenderQueue(Engine* engine) {
    
}

void RenderQueue::pushPrimitive(RenderElement element) {
    items.push_back(element);
}

void RenderQueue::render(Camera* camera, MaterialPtr replaceMaterial, Layer mask) {
    
}

void RenderQueue::clear() {
    items.clear();
}

void RenderQueue::destroy() {
    
}

void RenderQueue::sort(std::function<bool(const RenderElement&, const RenderElement&)> compareFunc) {
    std::sort(items.begin(), items.end(), compareFunc);
}

bool RenderQueue::_compareFromNearToFar(const RenderElement& a, const RenderElement& b) {
    return (a.material->renderQueueType < b.material->renderQueueType) ||
    (a.component->_distanceForSort < b.component->_distanceForSort) ||
    (b.component->_renderSortId < a.component->_renderSortId);
}

bool RenderQueue::_compareFromFarToNear(const RenderElement& a, const RenderElement& b) {
    return (a.material->renderQueueType < b.material->renderQueueType) ||
    (b.component->_distanceForSort < a.component->_distanceForSort) ||
    (b.component->_renderSortId < a.component->_renderSortId);
}

}
