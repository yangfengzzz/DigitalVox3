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
class Canvas;

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

class UnlitMaterial;

using UnlitMaterialPtr = std::shared_ptr<UnlitMaterial>;

class BlinnPhongMaterial;

using BlinnPhongMaterialPtr = std::shared_ptr<BlinnPhongMaterial>;

class PBRMaterial;

using PBRMaterialPtr = std::shared_ptr<PBRMaterial>;

class Camera;

class Renderer;

class MeshRenderer;

class GPUSkinnedMeshRenderer;

class Script;

class Animator;

class SceneAnimator;

class Light;

class PointLight;

class SpotLight;

class DirectLight;

class ShaderProgram;

class RenderPipelineState;

class ComputePipelineState;

class RenderPass;

class RenderElement;

class RenderQueue;

class MetalRenderer;

class MetalLoader;

using MetalLoaderPtr = std::shared_ptr<MetalLoader>;
}

#endif /* vox_type_h */
