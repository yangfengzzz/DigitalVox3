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

#ifndef VOX_ANIMATION_OFFLINE_FBX_FBX2VOX_H_
#define VOX_ANIMATION_OFFLINE_FBX_FBX2VOX_H_

#include "offline/animation/tools/import2vox.h"

#include "offline/animation/fbx/fbx.h"

// fbx2vox is a command line tool that converts an animation imported from a
// fbx document to vox runtime format.
//
// fbx2vox extracts animated joints from a fbx document. Only the animated
// joints whose names match those of the vox runtime skeleton given as argument
// are selected. Keyframes are then optimized, based on command line settings,
// and serialized as a runtime animation to an vox binary archive.
//
// Use fbx2vox integrated help command (fbx2vox --help) for more details
// about available arguments.

class Fbx2VoxImporter : public vox::animation::offline::VoxImporter {
 public:
  Fbx2VoxImporter();
  ~Fbx2VoxImporter();

 private:
  virtual bool Load(const char* _filename);

  // Skeleton management
  virtual bool Import(vox::animation::offline::RawSkeleton* _skeleton,
                      const NodeType& _types);

  // Animation management
  virtual AnimationNames GetAnimationNames();

  virtual bool Import(const char* _animation_name,
                      const vox::animation::Skeleton& _skeleton,
                      float _sampling_rate,
                      vox::animation::offline::RawAnimation* _animation);

  // Track management
  virtual NodeProperties GetNodeProperties(const char* _node_name);

  virtual bool Import(const char* _animation_name, const char* _node_name,
                      const char* _track_name,
                      NodeProperty::Type _expected_type, float _sampling_rate,
                      vox::animation::offline::RawFloatTrack* _track);

  virtual bool Import(const char* _animation_name, const char* _node_name,
                      const char* _track_name,
                      NodeProperty::Type _expected_type, float _sampling_rate,
                      vox::animation::offline::RawFloat2Track* _track);

  virtual bool Import(const char* _animation_name, const char* _node_name,
                      const char* _track_name,
                      NodeProperty::Type _expected_type, float _sampling_rate,
                      vox::animation::offline::RawFloat3Track* _track);

  virtual bool Import(const char* _animation_name, const char* _node_name,
                      const char* _track_name,
                      NodeProperty::Type _expected_type, float _sampling_rate,
                      vox::animation::offline::RawFloat4Track* _track);

  // Fbx internal helpers
  vox::animation::offline::fbx::FbxManagerInstance fbx_manager_;
  vox::animation::offline::fbx::FbxAnimationIOSettings settings_;
  vox::animation::offline::fbx::FbxSceneLoader* scene_loader_;
};
#endif  // VOX_ANIMATION_OFFLINE_FBX_FBX2VOX_H_
