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

#include "import2vox_skel.h"

#include <cstdlib>
#include <cstring>
#include <iomanip>

#include "import2vox_config.h"

#include "offline/animation/tools/import2vox.h"

#include "offline/animation/raw_skeleton.h"
#include "offline/animation/skeleton_builder.h"

#include "runtime/animation/skeleton.h"

#include "containers/map.h"
#include "containers/set.h"

#include "io/archive.h"
#include "io/stream.h"

#include "memory/unique_ptr.h"

#include "log.h"

#include "json/json.h"

namespace vox {
namespace animation {
namespace offline {
namespace {

// Uses a set to detect names uniqueness.
typedef vox::set<const char*, vox::str_less> Names;

bool ValidateJointNamesUniquenessRecurse(
    const RawSkeleton::Joint::Children& _joints, Names* _names) {
  for (size_t i = 0; i < _joints.size(); ++i) {
    const RawSkeleton::Joint& joint = _joints[i];
    const char* name = joint.name.c_str();
    if (!_names->insert(name).second) {
      vox::log::Err()
          << "Skeleton contains at least one non-unique joint name \"" << name
          << "\", which is not supported." << std::endl;
      return false;
    }
    if (!ValidateJointNamesUniquenessRecurse(_joints[i].children, _names)) {
      return false;
    }
  }
  return true;
}

bool ValidateJointNamesUniqueness(const RawSkeleton& _skeleton) {
  Names joint_names;
  return ValidateJointNamesUniquenessRecurse(_skeleton.roots, &joint_names);
}

void LogHierarchy(const RawSkeleton::Joint::Children& _children,
                  int _depth = 0) {
  const std::streamsize pres = vox::log::LogV().stream().precision();
  for (size_t i = 0; i < _children.size(); ++i) {
    const RawSkeleton::Joint& joint = _children[i];
    vox::log::LogV() << std::setw(_depth) << std::setfill('.') << "";
    vox::log::LogV() << joint.name.c_str() << std::setprecision(4)
                     << " t: " << joint.transform.translation.x << ", "
                     << joint.transform.translation.y << ", "
                     << joint.transform.translation.z
                     << " r: " << joint.transform.rotation.x << ", "
                     << joint.transform.rotation.y << ", "
                     << joint.transform.rotation.z << ", "
                     << joint.transform.rotation.w
                     << " s: " << joint.transform.scale.x << ", "
                     << joint.transform.scale.y << ", "
                     << joint.transform.scale.z << std::endl;

    // Recurse
    LogHierarchy(joint.children, _depth + 1);
  }
  vox::log::LogV() << std::setprecision(static_cast<int>(pres));
}
}  // namespace

bool ImportSkeleton(const Json::Value& _config, VoxImporter* _importer,
                    const vox::Endianness _endianness) {
  const Json::Value& skeleton_config = _config["skeleton"];
  const Json::Value& import_config = skeleton_config["import"];

  // First check that we're actually expecting to import a skeleton.
  if (!import_config["enable"].asBool()) {
    vox::log::Log() << "Skeleton build disabled, import will be skipped."
                    << std::endl;
    return true;
  }

  // Setup node types import properties.
  const Json::Value& types_config = import_config["types"];
  VoxImporter::NodeType types = {0};
  types.skeleton = types_config["skeleton"].asBool();
  types.marker = types_config["marker"].asBool();
  types.camera = types_config["camera"].asBool();
  types.geometry = types_config["geometry"].asBool();
  types.light = types_config["light"].asBool();
  types.any = types_config["any"].asBool();

  RawSkeleton raw_skeleton;
  if (!_importer->Import(&raw_skeleton, types)) {
    vox::log::Err() << "Failed to import skeleton." << std::endl;
    return false;
  }

  // Log skeleton hierarchy
  if (vox::log::GetLevel() == vox::log::kVerbose) {
    LogHierarchy(raw_skeleton.roots);
  }

  // Non unique joint names are not supported.
  if (!(ValidateJointNamesUniqueness(raw_skeleton))) {
    // Log Err is done by the validation function.
    return false;
  }

  // Needs to be done before opening the output file, so that if it fails then
  // there's no invalid file outputted.
  unique_ptr<Skeleton> skeleton;
  if (!import_config["raw"].asBool()) {
    // Builds runtime skeleton.
    vox::log::Log() << "Builds runtime skeleton." << std::endl;
    SkeletonBuilder builder;
    skeleton = builder(raw_skeleton);
    if (!skeleton) {
      vox::log::Err() << "Failed to build runtime skeleton." << std::endl;
      return false;
    }
  }

  // Prepares output stream. File is a RAII so it will close automatically at
  // the end of this scope.
  // Once the file is opened, nothing should fail as it would leave an invalid
  // file on the disk.
  {
    const char* filename = skeleton_config["filename"].asCString();
    vox::log::Log() << "Opens output file: " << filename << std::endl;
    vox::io::File file(filename, "wb");
    if (!file.opened()) {
      vox::log::Err() << "Failed to open output file: \"" << filename << "\"."
                      << std::endl;
      return false;
    }

    // Initializes output archive.
    vox::io::OArchive archive(&file, _endianness);

    // Fills output archive with the skeleton.
    if (import_config["raw"].asBool()) {
      vox::log::Log() << "Outputs RawSkeleton to binary archive." << std::endl;
      archive << raw_skeleton;
    } else {
      vox::log::Log() << "Outputs Skeleton to binary archive." << std::endl;
      archive << *skeleton;
    }
    vox::log::Log() << "Skeleton binary archive successfully outputted."
                    << std::endl;
  }

  return true;
}
}  // namespace offline
}  // namespace animation
}  // namespace vox