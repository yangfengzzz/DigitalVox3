//
//  render_pass.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "render_pass.h"

namespace vox {
size_t RenderPass::passNum = 0;

RenderPass::RenderPass(const std::string &name,
                       int priority,
                       MTLRenderPassDescriptor *renderTarget,
                       Layer mask) {
    if (name != "") {
        this->name = name;
    } else {
        this->name = "RENDER_PASS" + std::to_string(RenderPass::passNum);
        RenderPass::passNum += 1;
    }
    enabled = true;
    this->priority = priority;
    this->renderTarget = renderTarget;
    this->mask = mask;
    renderOverride = false; // If renderOverride is set to true, you need to implement the render method
}

}
