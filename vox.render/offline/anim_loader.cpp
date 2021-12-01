//
//  anim_loader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#include "anim_loader.h"
#include "../log.h"
#include "../io/archive.h"

namespace vox {
namespace offline {
namespace loader {
bool LoadSkeleton(const char* _filename, animation::Skeleton* _skeleton) {
    assert(_filename && _skeleton);
    log::Out() << "Loading skeleton archive " << _filename << "."
    << std::endl;
    io::File file(_filename, "rb");
    if (!file.opened()) {
        log::Err() << "Failed to open skeleton file " << _filename << "."
        << std::endl;
        return false;
    }
    io::IArchive archive(&file);
    if (!archive.TestTag<animation::Skeleton>()) {
        log::Err() << "Failed to load skeleton instance from file "
        << _filename << "." << std::endl;
        return false;
    }
    
    // Once the tag is validated, reading cannot fail.
    archive >> *_skeleton;
    
    return true;
}

bool LoadAnimation(const char* _filename, animation::Animation* _animation) {
    assert(_filename && _animation);
    log::Out() << "Loading animation archive: " << _filename << "."
    << std::endl;
    io::File file(_filename, "rb");
    if (!file.opened()) {
        log::Err() << "Failed to open animation file " << _filename << "."
        << std::endl;
        return false;
    }
    io::IArchive archive(&file);
    if (!archive.TestTag<animation::Animation>()) {
        log::Err() << "Failed to load animation instance from file "
        << _filename << "." << std::endl;
        return false;
    }
    
    // Once the tag is validated, reading cannot fail.
    archive >> *_animation;
    
    return true;
}

namespace {
template <typename _Track>
bool LoadTrackImpl(const char* _filename, _Track* _track) {
    assert(_filename && _track);
    log::Out() << "Loading track archive: " << _filename << "." << std::endl;
    io::File file(_filename, "rb");
    if (!file.opened()) {
        log::Err() << "Failed to open track file " << _filename << "."
        << std::endl;
        return false;
    }
    io::IArchive archive(&file);
    if (!archive.TestTag<_Track>()) {
        log::Err() << "Failed to load float track instance from file "
        << _filename << "." << std::endl;
        return false;
    }
    
    // Once the tag is validated, reading cannot fail.
    archive >> *_track;
    
    return true;
}
}  // namespace

bool LoadTrack(const char* _filename, animation::FloatTrack* _track) {
    return LoadTrackImpl(_filename, _track);
}

bool LoadTrack(const char* _filename, animation::Float2Track* _track) {
    return LoadTrackImpl(_filename, _track);
}

bool LoadTrack(const char* _filename, animation::Float3Track* _track) {
    return LoadTrackImpl(_filename, _track);
}

bool LoadTrack(const char* _filename, animation::Float4Track* _track) {
    return LoadTrackImpl(_filename, _track);
}

bool LoadTrack(const char* _filename, animation::QuaternionTrack* _track) {
    return LoadTrackImpl(_filename, _track);
}

} // loader
} // offline
} // vox
