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
class Mesh;
using MeshPtr = std::shared_ptr<Mesh>;
class ModelMesh;
using ModelMeshPtr = std::shared_ptr<ModelMesh>;
class Material;
using MaterialPtr = std::shared_ptr<Material>;
class Camera;
class Renderer;
class Script;

}

#endif /* vox_type_h */
