**Depreciate!!! If you like C++ please refer to [DigitalVox4](https://github.com/yangfengzzz/DigitalVox4), Or [SwiftArche](https://github.com/ArcheGraphics/SwiftArche) **

# DigitalVox3 - Metal Graphics Engine

This project is inspired by [Oasis](https://github.com/oasis-engine) which is an ECS-liked based engine(not very strict)
. Based on entity and component, it is easy to combine other open-source ability:

1. [ImGui](https://github.com/ocornut/imgui): GUI system
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

### GPU Skinning Animation with GLTF

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/gltf_view.mm) can also load animation which
control the tree of entities. GPU Skinning Animation limit the joint weight have only four component.

![GPU Animation](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/gpu_animation.gif "GPU Animation")

### CPU Animation System with FBX

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/windows_view.mm) about CPU animation system which
is based on [OZZ-Animation](https://github.com/guillaumeblanc/ozz-animation). Ozz support CPU skinning, blending, IK and
other animation ability. The CPU animation system does not limit the number of weights of the bones, so it will be more
free to use.
![Animation Simulation](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/animation.gif "Animation Simulation")

### CPU Particle System

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/particle_view.mm) about CPU particle system which
can load [fluid-engine-dev](https://github.com/doyubkim/fluid-engine-dev) solvers.
![Particle Simulation](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/particle_sim.gif "Particle Simulation")

### Physics System

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/physx_dynamic_view.mm) about Physics System which
is based on [PhysX](https://github.com/NVIDIAGameWorks/PhysX). Collider, Joint, Character Controller are all wrapped as
component which is more easy to use.

![PhysX](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/physx.gif "PhysX")

### PBR

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/ibl_view.mm) use IBL to render basic pbr scene.
The specular-map is generated by using compute shader. The diffuse-map is generated
by [Model I/O framework](https://developer.apple.com/documentation/modelio/mdltexture/1391909-irradiancetexturecubewithtexture/)

![IBL](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/ibl.gif "IBL")

### Shadow System

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/shadowMap_view.mm) support multi-shadow from three
kind of lights. All these based on ShadowMap.

1. spot light: single shadow map
2. directional light: cascaded shadow map(render four times)
3. point light: shadow cube map (render six times)

![Multi Shadow](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/multi_shadow.gif "Multi Shadow")
![Cube Shadow from Point](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/cube_shadow.gif "Cube Shadow from Point")

### Deferred Render Pipeline

[Example](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/modelio_view.mm) use 256 point lights to shader
the whole scene which need deferred render pipeline to reduce fragment wastes.

![Deferred Render Pipeline](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/deferred.gif "Deferred Render Pipeline")

### GUI

[Editor](https://github.com/yangfengzzz/DigitalVox3/blob/master/editor/gui_entry.h) use IMGUI to render gui
and [FrameBuffer Picker](https://github.com/yangfengzzz/DigitalVox3/blob/master/apps/framebufferPicker_view.mm) to link
the scene with panel. [ImGuizmo](https://github.com/CedricGuillemet/ImGuizmo)
and [imgui-node-editor](https://github.com/thedmd/imgui-node-editor) build the basic infrastructure of editor.

![Editor](https://github.com/yangfengzzz/DigitalVox3/raw/master/doc/img/editor.gif "Editor")
