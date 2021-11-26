//
//  updateFlag_manager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "updateFlag_manager.h"

namespace vox {
std::unique_ptr<UpdateFlag> UpdateFlagManager::registration() {
    return std::make_unique<UpdateFlag>(this);
}

void UpdateFlagManager::distribute() {
    for (size_t i = _updateFlags.size() - 1; i >= 0; i--) {
        _updateFlags[i]->flag = true;
    }
}
}
