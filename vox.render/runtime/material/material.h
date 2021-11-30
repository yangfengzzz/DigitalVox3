//
//  material.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef material_hpp
#define material_hpp

#include "../engine_object.h"
#include "../shader/shader.h"
#include "../shader/shader_data.h"
#include "../shader/state/render_state.h"
#include "enums/render_queue_type.h"

namespace vox {
/// Material.
class Material: EngineObject {
public:
    /// Name.
    std::string name = "";
    /// Shader used by the material.
    Shader* shader;
    /// Render queue type.
    RenderQueueType renderQueueType = RenderQueueType::Opaque;
    /// Shader data.
    ShaderData shaderData = ShaderData();
    /// Render state.
    RenderState renderState = RenderState();
    
    /// Create a material instance.
    /// - Parameters:
    ///   - engine: Engine to which the material belongs
    ///   - shader: Shader used by the material
    Material(Engine* engine, Shader* shader);
};

}

#endif /* material_hpp */
