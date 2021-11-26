//
//  updateFlag_manager.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef updateFlag_manager_hpp
#define updateFlag_manager_hpp

#include <memory>
#include <vector>
#include "updateFlag.h"

namespace ozz {
class UpdateFlagManager {
public:
    std::unique_ptr<UpdateFlag> registration();
    
    void distribute();
    
private:
    friend class UpdateFlag;
    std::vector<UpdateFlag *> _updateFlags;
};

}
#endif /* updateFlag_manager_hpp */
