//----------------------------------------------------------------------------//
//                                                                            //
// vox-animation is hosted at http://github.com/guillaumeblanc/vox-animation  //
// and distributed under the MIT License (MIT).                               //
//                                                                            //
// Copyright (c) Guillaume Blanc                                              //
//                                                                            //
// Permission is hereby granted, free of charge, to any person obtaining a    //
// copy of this software and associated documentation files (the "Software"), //
// to deal in the Software without restriction, including without limitation  //
// the rights to use, copy, modify, merge, publish, distribute, sublicense,   //
// and/or sell copies of the Software, and to permit persons to whom the      //
// Software is furnished to do so, subject to the following conditions:       //
//                                                                            //
// The above copyright notice and this permission notice shall be included in //
// all copies or substantial portions of the Software.                        //
//                                                                            //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    //
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    //
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER        //
// DEALINGS IN THE SOFTWARE.                                                  //
//                                                                            //
//----------------------------------------------------------------------------//

#include "fbx2vox.h"

#include "offline/animation/fbx/fbx_animation.h"

#include "offline/animation/raw_animation.h"

#include "log.h"

Fbx2VoxImporter::AnimationNames Fbx2VoxImporter::GetAnimationNames() {
  if (!scene_loader_) {
    return AnimationNames();
  }
  return vox::animation::offline::fbx::GetAnimationNames(*scene_loader_);
}

bool Fbx2VoxImporter::Import(
    const char* _animation_name, const vox::animation::Skeleton& _skeleton,
    float _sampling_rate, vox::animation::offline::RawAnimation* _animation) {
  if (!_animation) {
    return false;
  }

  *_animation = vox::animation::offline::RawAnimation();

  if (!scene_loader_) {
    return false;
  }

  return vox::animation::offline::fbx::ExtractAnimation(
      _animation_name, *scene_loader_, _skeleton, _sampling_rate, _animation);
}

Fbx2VoxImporter::NodeProperties Fbx2VoxImporter::GetNodeProperties(
    const char* _node_name) {
  if (!scene_loader_) {
    return NodeProperties();
  }

  return vox::animation::offline::fbx::GetNodeProperties(*scene_loader_,
                                                         _node_name);
}

template <typename _RawTrack>
bool ImportImpl(vox::animation::offline::fbx::FbxSceneLoader* _scene_loader,
                const char* _animation_name, const char* _node_name,
                const char* _track_name,
                Fbx2VoxImporter::NodeProperty::Type _type, float _sampling_rate,
                _RawTrack* _track) {
  if (!_scene_loader) {
    return false;
  }
  return vox::animation::offline::fbx::ExtractTrack(
      _animation_name, _node_name, _track_name, _type, *_scene_loader,
      _sampling_rate, _track);
}

bool Fbx2VoxImporter::Import(const char* _animation_name,
                             const char* _node_name, const char* _track_name,
                             Fbx2VoxImporter::NodeProperty::Type _type,
                             float _sampling_rate,
                             vox::animation::offline::RawFloatTrack* _track) {
  return ImportImpl(scene_loader_, _animation_name, _node_name, _track_name,
                    _type, _sampling_rate, _track);
}

bool Fbx2VoxImporter::Import(const char* _animation_name,
                             const char* _node_name, const char* _track_name,
                             Fbx2VoxImporter::NodeProperty::Type _type,
                             float _sampling_rate,
                             vox::animation::offline::RawFloat2Track* _track) {
  return ImportImpl(scene_loader_, _animation_name, _node_name, _track_name,
                    _type, _sampling_rate, _track);
}

bool Fbx2VoxImporter::Import(const char* _animation_name,
                             const char* _node_name, const char* _track_name,
                             Fbx2VoxImporter::NodeProperty::Type _type,
                             float _sampling_rate,
                             vox::animation::offline::RawFloat3Track* _track) {
  return ImportImpl(scene_loader_, _animation_name, _node_name, _track_name,
                    _type, _sampling_rate, _track);
}

bool Fbx2VoxImporter::Import(const char* _animation_name,
                             const char* _node_name, const char* _track_name,
                             Fbx2VoxImporter::NodeProperty::Type _type,
                             float _sampling_rate,
                             vox::animation::offline::RawFloat4Track* _track) {
  return ImportImpl(scene_loader_, _animation_name, _node_name, _track_name,
                    _type, _sampling_rate, _track);
}
