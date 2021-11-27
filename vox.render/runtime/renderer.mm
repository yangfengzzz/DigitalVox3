//
//  renderer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "renderer.h"

namespace vox {
ShaderProperty Renderer::_localMatrixProperty = Shader::getPropertyByName("u_localMat");
ShaderProperty Renderer::_worldMatrixProperty = Shader::getPropertyByName("u_modelMat");
ShaderProperty Renderer::_mvMatrixProperty = Shader::getPropertyByName("u_MVMat");
ShaderProperty Renderer::_mvpMatrixProperty = Shader::getPropertyByName("u_MVPMat");
ShaderProperty Renderer::_mvInvMatrixProperty = Shader::getPropertyByName("u_MVInvMat");
ShaderProperty Renderer::_normalMatrixProperty = Shader::getPropertyByName("u_normalMat");

size_t Renderer::materialCount() {
    return _materials.size();
}

BoundingBox Renderer::bounds() {
    auto& changeFlag = _transformChangeFlag;
    if (changeFlag.flag) {
        _updateBounds(_bounds);
        changeFlag.flag = false;
    }
    return _bounds;
}

}
