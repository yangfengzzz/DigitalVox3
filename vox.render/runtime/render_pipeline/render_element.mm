//
//  render_element.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "render_element.h"

namespace vox {
RenderElement::RenderElement(Renderer* component, MeshPtr mesh, SubMesh* subMesh, MaterialPtr material) {
    this->component = component;
    this->mesh = mesh;
    this->subMesh = subMesh;
    this->material = material;
}

}
