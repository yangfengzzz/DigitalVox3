//
//  updateFlag.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "updateFlag.h"
#include "updateFlag_manager.h"

namespace ozz {
UpdateFlag::UpdateFlag(UpdateFlagManager *_flags) : _flags(_flags) {
    _flags->_updateFlags.push_back(this);
}

void UpdateFlag::destroy() {
    _flags->_updateFlags.erase(std::remove(_flags->_updateFlags.begin(),
                                           _flags->_updateFlags.end(), this), _flags->_updateFlags.end());
}

}
