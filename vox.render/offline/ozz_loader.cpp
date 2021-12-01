//
//  ozz_loader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#include "ozz_loader.h"

namespace vox {
namespace offline {
namespace loader {
bool LoadSkeleton(const char* _filename, animation::Skeleton* _skeleton) {
    return false;
}

bool LoadAnimation(const char* _filename, animation::Animation* _animation) {
    return false;
}

bool LoadTrack(const char* _filename, animation::FloatTrack* _track) {
    return false;
}

bool LoadTrack(const char* _filename, animation::Float2Track* _track) {
    return false;
}

bool LoadTrack(const char* _filename, animation::Float3Track* _track) {
    return false;
}

bool LoadTrack(const char* _filename, animation::Float4Track* _track) {
    return false;
}

bool LoadTrack(const char* _filename, animation::QuaternionTrack* _track) {
    return false;
}

} // loader
} // offline
} // vox
