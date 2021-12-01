//
//  ozz_loader.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#ifndef ozz_loader_hpp
#define ozz_loader_hpp

#include "../runtime/animation/skeleton.h"
#include "../runtime/animation/animation.h"
#include "../runtime/animation/track.h"

namespace vox {
namespace offline {
namespace loader {
// Loads a skeleton from an ozz archive file named _filename.
// This function will fail and return false if the file cannot be opened or if
// it is not a valid ozz skeleton archive. A valid skeleton archive can be
// produced with ozz tools (fbx2ozz) or using ozz skeleton serialization API.
// _filename and _skeleton must be non-nullptr.
bool LoadSkeleton(const char* _filename, animation::Skeleton* _skeleton);

// Loads an animation from an ozz archive file named _filename.
// This function will fail and return false if the file cannot be opened or if
// it is not a valid ozz animation archive. A valid animation archive can be
// produced with ozz tools (fbx2ozz) or using ozz animation serialization API.
// _filename and _animation must be non-nullptr.
bool LoadAnimation(const char* _filename, animation::Animation* _animation);

// Loads a float track from an ozz archive file named _filename.
// This function will fail and return false if the file cannot be opened or if
// it is not a valid ozz float track archive. A valid float track archive can be
// produced with ozz tools (fbx2ozz) or using ozz serialization API.
// _filename and _track must be non-nullptr.
bool LoadTrack(const char* _filename, animation::FloatTrack* _track);
bool LoadTrack(const char* _filename, animation::Float2Track* _track);
bool LoadTrack(const char* _filename, animation::Float3Track* _track);
bool LoadTrack(const char* _filename, animation::Float4Track* _track);
bool LoadTrack(const char* _filename, animation::QuaternionTrack* _track);
}
}
}

#endif /* ozz_loader_hpp */
