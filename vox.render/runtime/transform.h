//
//  transform.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef transform_hpp
#define transform_hpp

#include "component.h"

namespace ozz {
/**
 * Used to implement transformation related functions.
 */
class Transform : public Component {
    
    
};

/**
 * Dirty flag of transform.
 */
enum TransformFlag {
    LocalEuler = 0x1,
    LocalQuat = 0x2,
    WorldPosition = 0x4,
    WorldEuler = 0x8,
    WorldQuat = 0x10,
    WorldScale = 0x20,
    LocalMatrix = 0x40,
    WorldMatrix = 0x80,
    
    /** WorldMatrix | WorldPosition */
    WmWp = 0x84,
    /** WorldMatrix | WorldEuler | WorldQuat */
    WmWeWq = 0x98,
    /** WorldMatrix | WorldPosition | WorldEuler | WorldQuat */
    WmWpWeWq = 0x9c,
    /** WorldMatrix | WorldScale */
    WmWs = 0xa0,
    /** WorldMatrix | WorldPosition | WorldScale */
    WmWpWs = 0xa4,
    /** WorldMatrix | WorldPosition | WorldEuler | WorldQuat | WorldScale */
    WmWpWeWqWs = 0xbc
};


}

#endif /* transform_hpp */
