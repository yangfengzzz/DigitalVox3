# DigitalVox3 - Metal Graphics Engine

This project is inspired by [Oasis](https://github.com/oasis-engine) which is an ECS-liked based engine(not very strict)
. Based on entity and component, it is easy to combine other open-source ability:

1. [IMGUI](https://github.com/ocornut/imgui): GUI system
2. [OZZ-Animation](https://github.com/guillaumeblanc/ozz-animation): CPU Animation System
3. [PhysX](https://github.com/NVIDIAGameWorks/PhysX): Physical System
4. [fluid-engine-dev](https://github.com/doyubkim/fluid-engine-dev): Fluid Simulation and CPU Particle System

Which can load a lot of model format including:

1. [FBX](https://www.autodesk.com/developer-network/platform-technologies/fbx-sdk-2016-1-2): FBX loader with Ozz
   animation
2. [GLTF](https://github.com/syoyo/tinygltf): GLTF Loader with GPU-based Skinning Animation
3. [Other](https://developer.apple.com/documentation/modelio/mdlasset/1391813-canimportfileextension): OBJ and other
   format loaded by ModelIO Framework

## Features

### GLTF Loader

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/gltf_view.mm) about GLTF Loader which based
on [GLTF](https://github.com/syoyo/tinygltf)
![GLTF Scene](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/gltf_scene.gif "GLTF Scene")

### GPU Skinning Animation

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/gltf_view.mm) can also load animation which
control the tree of entities. GPU Skinning Animation limit the joint weight have only four component.

![GPU Animation](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/gpu_animation.gif "GPU Animation")

### CPU Animation System

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/windows_view.mm) about CPU animation system which
is based on [OZZ-Animation](https://github.com/guillaumeblanc/ozz-animation). Ozz support CPU skinning, blending, IK and
other animation ability. The CPU animation system does not limit the number of weights of the bones, so it will be more
free to use.
![Animation Simulation](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/animation.gif "Animation Simulation")

### CPU Particle System

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/particle_view.mm) about CPU particle system which
can load [fluid-engine-dev](https://github.com/doyubkim/fluid-engine-dev) solvers.
![Particle Simulation](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/particle_sim.gif "Particle Simulation")