//
//  timer.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "timer.h"

namespace vox {
Timer::Timer() :
start_time{Clock::now()},
previous_tick{Clock::now()} {
}

void Timer::reset() {
    previous_tick = Clock::now();
}

void Timer::start() {
    if (!running) {
        running = true;
        start_time = Clock::now();
    }
}

void Timer::lap() {
    lapping = true;
    lap_time = Clock::now();
}

bool Timer::is_running() const {
    return running;
}

}
