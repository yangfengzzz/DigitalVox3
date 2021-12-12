//
//  grid.cpp
//  editor
//
//  Created by 杨丰 on 2021/12/12.
//

#include "grid.h"
#include "../vox.render/runtime/entity.h"
#include "../vox.render/runtime/mesh/mesh_renderer.h"
#include "../vox.render/runtime/mesh/model_mesh.h"
#include "../vox.render/runtime/engine.h"
#include "../vox.render/runtime/material/material.h"

namespace vox {
namespace editor {
class GridMaterial: public Material {
public:
    GridMaterial(Engine* engine): Material(engine, Shader::find("editor-grid")) {}
};

Grid::Grid(Entity *entity):
Script(entity){
    Shader::create("editor-grid", "vertex_grid", "fragment_grid");

    _renderer = entity->addComponent<MeshRenderer>();
    _renderer->setMesh(createPlane(engine()));
    _renderer->setMaterial(std::make_shared<GridMaterial>(engine()));
}

ModelMeshPtr Grid::createPlane(Engine* engine) {
    auto mesh = std::make_shared<ModelMesh>(engine);
    
    auto positions = std::vector<Float3>(4);
    positions[0] = Float3(-1, -1, 0);
    positions[1] = Float3(1, -1, 0);
    positions[2] = Float3(-1, 1, 0);
    positions[3] = Float3(1, 1, 0);
    
    auto indices = std::vector<uint32_t>(6);
    indices[0] = 1;
    indices[1] = 2;
    indices[2] = 0;
    indices[3] = 1;
    indices[4] = 3;
    indices[5] = 2;
    
    mesh->setPositions(positions);
    mesh->uploadData(true);
    const auto indexBuffer = [engine->_hardwareRenderer.device newBufferWithBytes:indices.data()
                                                                           length:indices.size() * sizeof(uint32_t)
                                                                          options:MTLResourceStorageModeShared];
    
    mesh->addSubMesh(MeshBuffer(indexBuffer, indices.size() * sizeof(uint32_t), MDLMeshBufferTypeIndex),
                     MTLIndexTypeUInt32, indices.size(), MTLPrimitiveTypeTriangle);
    
    return mesh;
}

}
}
