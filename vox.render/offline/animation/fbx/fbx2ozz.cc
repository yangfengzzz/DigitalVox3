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

#include "log.h"

int main(int _argc, const char** _argv) {
  Fbx2VoxImporter converter;
  return converter(_argc, _argv);
}

Fbx2VoxImporter::Fbx2VoxImporter()
    : settings_(fbx_manager_), scene_loader_(nullptr) {}

Fbx2VoxImporter::~Fbx2VoxImporter() { vox::Delete(scene_loader_); }

bool Fbx2VoxImporter::Load(const char* _filename) {
  vox::Delete(scene_loader_);
  scene_loader_ = vox::New<vox::animation::offline::fbx::FbxSceneLoader>(
      _filename, "", fbx_manager_, settings_);

  if (!scene_loader_->scene()) {
    vox::log::Err() << "Failed to import file " << _filename << "."
                    << std::endl;
    vox::Delete(scene_loader_);
    scene_loader_ = nullptr;
    return false;
  }
  return true;
}
