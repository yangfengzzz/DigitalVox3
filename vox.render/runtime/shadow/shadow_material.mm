//
//  shadow_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/20.
//

#include "shadow_material.h"

namespace vox {
ShadowMaterial::ShadowMaterial(Engine* engine):
Material(engine, Shader::find("shadow")) {
    auto& targetBlendState = renderState.blendState.targetBlendState;
    targetBlendState.enabled = true;
    targetBlendState.sourceColorBlendFactor = targetBlendState.sourceAlphaBlendFactor = MTLBlendFactorDestinationColor;
    targetBlendState.destinationColorBlendFactor = targetBlendState.destinationAlphaBlendFactor = MTLBlendFactorZero;
    renderState.depthState.compareFunction = MTLCompareFunctionLessEqual;
    
    renderQueueType = RenderQueueType::Enum::Transparent;
}

}
