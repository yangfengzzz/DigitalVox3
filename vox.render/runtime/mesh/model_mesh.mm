//
//  model_mesh.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "model_mesh.h"

namespace vox {
bool ModelMesh::accessible() {
    return _accessible;
}

size_t ModelMesh::vertexCount() {
    return _vertexCount;
}

ModelMesh::ModelMesh(Engine* engine, const std::string& name):
Mesh(engine, name){
    
}

}
