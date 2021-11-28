//
//  render_element.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_element_hpp
#define render_element_hpp

#include "../vox_type.h"

namespace vox {
/// Render element.
struct RenderElement {
    /// Render component.
    Renderer* component;
    /// Mesh.
    MeshPtr mesh;
    /// Sub mesh.
    SubMesh* subMesh;
    /// Material.
    MaterialPtr material;

    RenderElement(Renderer* component, MeshPtr mesh, SubMesh* subMesh, MaterialPtr material);
};

}

#endif /* render_element_hpp */
