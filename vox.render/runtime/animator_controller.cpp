//
//  animatorController.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/1.
//

#include "animator_controller.h"
#include "maths/math_ex.h"

namespace vox {
AnimatorController::AnimatorController()
: time_ratio_(0.f),
previous_time_ratio_(0.f),
playback_speed_(1.f),
play_(true),
loop_(true) {}

void AnimatorController::Update(const animation::Animation& _animation,
                                float _dt) {
    float new_time = time_ratio_;
    
    if (play_) {
        new_time = time_ratio_ + _dt * playback_speed_ / _animation.duration();
    }
    
    // Must be called even if time doesn't change, in order to update previous
    // frame time ratio. Uses set_time_ratio function in order to update
    // previous_time_ an wrap time value in the unit interval (depending on loop
    // mode).
    set_time_ratio(new_time);
}

void AnimatorController::set_time_ratio(float _ratio) {
    previous_time_ratio_ = time_ratio_;
    if (loop_) {
        // Wraps in the unit interval [0:1], even for negative values (the reason
        // for using floorf).
        time_ratio_ = _ratio - floorf(_ratio);
    } else {
        // Clamps in the unit interval [0:1].
        time_ratio_ = math::Clamp(0.f, _ratio, 1.f);
    }
}

// Gets animation current time.
float AnimatorController::time_ratio() const { return time_ratio_; }

// Gets animation time of last update.
float AnimatorController::previous_time_ratio() const {
    return previous_time_ratio_;
}

void AnimatorController::Reset() {
    previous_time_ratio_ = time_ratio_ = 0.f;
    playback_speed_ = 1.f;
    play_ = true;
}

//bool AnimatorController::OnGui(const animation::Animation& _animation,
//                               ImGui* _im_gui, bool _enabled,
//                               bool _allow_set_time) {
//    bool time_changed = false;
//
//    if (_im_gui->DoButton(play_ ? "Pause" : "Play", _enabled)) {
//        play_ = !play_;
//    }
//
//    _im_gui->DoCheckBox("Loop", &loop_, _enabled);
//
//    char szLabel[64];
//
//    // Uses a local copy of time_ so that set_time is used to actually apply
//    // changes. Otherwise previous time would be incorrect.
//    float ratio = time_ratio();
//    std::sprintf(szLabel, "Animation time: %.2f", ratio * _animation.duration());
//    if (_im_gui->DoSlider(szLabel, 0.f, 1.f, &ratio, 1.f,
//                          _enabled && _allow_set_time)) {
//        set_time_ratio(ratio);
//        // Pause the time if slider as moved.
//        play_ = false;
//        time_changed = true;
//    }
//    std::sprintf(szLabel, "Playback speed: %.2f", playback_speed_);
//    _im_gui->DoSlider(szLabel, -5.f, 5.f, &playback_speed_, 1.f, _enabled);
//
//    // Allow to reset speed if it is not the default value.
//    if (_im_gui->DoButton("Reset playback speed",
//                          playback_speed_ != 1.f && _enabled)) {
//        playback_speed_ = 1.f;
//    }
//    return time_changed;
//}

}
