//
//  vox_type.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/11/28.
//

#ifndef vox_type_h
#define vox_type_h

#include <memory>

namespace vox {
class Engine;
class Scene;
using ScenePtr = std::shared_ptr<Scene>;
class Entity;
using EntityPtr = std::shared_ptr<Entity>;
class SubMesh;
class Mesh;
using MeshPtr = std::shared_ptr<Mesh>;
class ModelMesh;
using ModelMeshPtr = std::shared_ptr<ModelMesh>;
class Material;
using MaterialPtr = std::shared_ptr<Material>;
class Camera;
class Renderer;
class Script;
class Animator;
class Light;

class ShaderProgram;
class RenderPipelineState;
class ComputePipelineState;
class RenderPass;
class RenderQueue;
class MetalRenderer;

}

#endif /* vox_type_h */
