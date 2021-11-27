//
//  render_element.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_element_hpp
#define render_element_hpp

#include <memory>

namespace vox {
class Renderer;
class Mesh;
using MeshPtr = std::shared_ptr<Mesh>;
class SubMesh;
class Material;
using MaterialPtr = std::shared_ptr<Material>;

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

    void setValue(Renderer* component, MeshPtr mesh, SubMesh* subMesh, MaterialPtr material);
};

}

#endif /* render_element_hpp */
