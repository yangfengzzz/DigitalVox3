//
//  base_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/29.
//

#include "base_material.h"

namespace vox {
ShaderProperty BaseMaterial::_alphaCutoffProp = Shader::createProperty("u_alphaCutoff", ShaderDataGroup::Material);

bool BaseMaterial::isTransparent() {
    return _isTransparent;
}

void BaseMaterial::setIsTransparent(bool newValue) {
    if (newValue == _isTransparent) {
        return;
    }
    _isTransparent = newValue;
    
    auto &depthState = renderState.depthState;
    auto &targetBlendState = renderState.blendState.targetBlendState;
    
    if (newValue) {
        targetBlendState.enabled = true;
        depthState.writeEnabled = false;
        renderQueueType = RenderQueueType::Transparent;
    } else {
        targetBlendState.enabled = false;
        depthState.writeEnabled = true;
        renderQueueType = (shaderData.getData(BaseMaterial::_alphaCutoffProp).has_value()) ? RenderQueueType::AlphaTest : RenderQueueType::Opaque;
    }
}

float BaseMaterial::alphaCutoff() {
    return std::any_cast<float>(shaderData.getData(BaseMaterial::_alphaCutoffProp));
}

void BaseMaterial::setAlphaCutoff(float newValue) {
    shaderData.setData(BaseMaterial::_alphaCutoffProp, newValue);
    
    if (newValue > 0) {
        shaderData.enableMacro(NEED_ALPHA_CUTOFF);
        renderQueueType = _isTransparent ? RenderQueueType::Transparent : RenderQueueType::AlphaTest;
    } else {
        shaderData.disableMacro(NEED_ALPHA_CUTOFF);
        renderQueueType = _isTransparent ? RenderQueueType::Transparent : RenderQueueType::Opaque;
    }
}

const RenderFace::Enum &BaseMaterial::renderFace() {
    return _renderFace;
}

void BaseMaterial::setRenderFace(const RenderFace::Enum &newValue) {
    _renderFace = newValue;
    
    switch (newValue) {
        case RenderFace::Front:
            renderState.rasterState.cullMode = MTLCullModeBack;
            break;
        case RenderFace::Back:
            renderState.rasterState.cullMode = MTLCullModeFront;
            break;
        case RenderFace::Double:
            renderState.rasterState.cullMode = MTLCullModeNone;
            break;
    }
}

const BlendMode::Enum &BaseMaterial::blendMode() {
    return _blendMode;
}

void BaseMaterial::setBlendMode(const BlendMode::Enum &newValue) {
    _blendMode = newValue;
    
    auto &target = renderState.blendState.targetBlendState;
    
    switch (newValue) {
        case BlendMode::Normal:
            target.sourceColorBlendFactor = MTLBlendFactorSourceAlpha;
            target.destinationColorBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
            target.sourceAlphaBlendFactor = MTLBlendFactorOne;
            target.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
            target.alphaBlendOperation = MTLBlendOperationAdd;
            target.colorBlendOperation = MTLBlendOperationAdd;
            break;
        case BlendMode::Additive:
            target.sourceColorBlendFactor = MTLBlendFactorSourceAlpha;
            target.destinationColorBlendFactor = MTLBlendFactorOne;
            target.sourceAlphaBlendFactor = MTLBlendFactorOne;
            target.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
            target.alphaBlendOperation = MTLBlendOperationAdd;
            target.colorBlendOperation = MTLBlendOperationAdd;
            break;
    }
}

BaseMaterial::BaseMaterial(Engine *engine, Shader *shader) :
Material(engine, shader) {
    setBlendMode(BlendMode::Enum::Normal);
    shaderData.setData(BaseMaterial::_alphaCutoffProp, 0.0f);
}

}
