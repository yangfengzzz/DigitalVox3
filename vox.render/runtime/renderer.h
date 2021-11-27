//
//  renderer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef renderer_hpp
#define renderer_hpp

#include "component.h"
#include "shader/shader.h"
#include "shader/shader_data.h"
#include "maths/matrix.h"
#include "maths/bounding_box.h"
#include "updateFlag.h"
#include "render_pipeline/render_context.h"
#include <vector>

namespace vox {
using namespace math;
class Material;
using MaterialPtr = std::shared_ptr<Material>;
class Camera;
class Entity;
using EntityPtr = std::shared_ptr<Entity>;

/// Renderable component.
class Renderer: public Component {
public:
    /// ShaderData related to renderer.
    ShaderData shaderData = ShaderData(ShaderDataGroup::Renderer);
    // @ignoreClone
    /// Whether it is clipped by the frustum, needs to be turned on camera.enableFrustumCulling.
    bool isCulled = false;
    
    /// Material count.
    size_t materialCount();
    
    /// The bounding volume of the renderer.
    BoundingBox bounds();
    
    Renderer(Entity* entity);
    
    void _onEnable() override;
    
    void _onDisable() override;
    
    void _onDestroy() override;
    
    virtual void _render(const Camera& camera) = 0;
    
    virtual void _updateBounds(const BoundingBox& worldBounds) = 0;
    
    virtual void update(float deltaTime) = 0;
    
public:
    //MARK:- Material Methods
    /// Get the first instance material by index.
    /// - Remark: Calling this function for the first time after the material is set
    /// will create an instance material to ensure that it is unique to the renderer.
    /// - Parameter index: Material index
    /// - Returns: Instance material
    MaterialPtr getInstanceMaterial(size_t index = 0);
    
    /// Get the first material by index.
    /// - Parameter index: Material index
    /// - Returns: Material
    MaterialPtr getMaterial(size_t index = 0);
    
    /// Set the first material.
    /// - Parameter material: The first material
    void setMaterial(MaterialPtr material);
    
    /// Set material by index.
    /// - Parameters:
    ///   - index: Material index
    ///   - material: The material
    void setMaterial(size_t index, MaterialPtr material);
    
    /// Get all instance materials.
    /// - Remark: Calling this function for the first time after the material is set
    ///  will create an instance material to ensure that it is unique to the renderer.
    /// - Returns: All instance materials
    std::vector<MaterialPtr> getInstanceMaterials();
    
    /// Get all materials.
    /// - Returns: All materials
    std::vector<MaterialPtr> getMaterials();
    
    /// Set all materials.
    /// - Parameter materials: All materials
    void setMaterials(const std::vector<MaterialPtr>& materials);
    
    
private:
    static ShaderProperty _localMatrixProperty;
    static ShaderProperty _worldMatrixProperty;
    static ShaderProperty _mvMatrixProperty;
    static ShaderProperty _mvpMatrixProperty;
    static ShaderProperty _mvInvMatrixProperty;
    static ShaderProperty _normalMatrixProperty;
    
    void _updateShaderData(const RenderContext& context);
    
    MaterialPtr _createInstanceMaterial(const MaterialPtr& material, size_t index);
    
    float _distanceForSort = 0;
    int _onUpdateIndex = -1;
    int _rendererIndex = -1;
    ShaderMacroCollection _globalShaderMacro = ShaderMacroCollection();
    int _renderSortId = 0;
    
    // @ignoreClone
    bool _overrideUpdate = false;
    // @shallowClone
    std::vector<std::shared_ptr<Material>> _materials;
    
    // @ignoreClone
    std::unique_ptr<UpdateFlag> _transformChangeFlag;
    // @deepClone
    BoundingBox _bounds = BoundingBox();
    // @ignoreClone
    Matrix _mvMatrix = Matrix();
    // @ignoreClone
    Matrix _mvpMatrix = Matrix();
    // @ignoreClone
    Matrix _mvInvMatrix = Matrix();
    // @ignoreClone
    Matrix _normalMatrix = Matrix();
    // @ignoreClone
    std::vector<bool> _materialsInstanced;
    
    /// Set whether the renderer to receive shadows.
    bool receiveShadow = false;
    /// Set whether the renderer to cast shadows.
    bool castShadow = false;
};

}

#endif /* renderer_hpp */
