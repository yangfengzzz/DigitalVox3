//
//  background.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#ifndef background_hpp
#define background_hpp

#include "vox_type.h"
#include "enums/background_mode.h"
#include "maths/color.h"

namespace vox {
/// Background of scene.
class Background {
public:
    /// Background mode.
    /// - Note: defaultValue `BackgroundMode.SolidColor`
    /// - Remark: If using `BackgroundMode.Sky` mode and material or mesh of the `sky` is not defined,
    /// it will downgrade to `BackgroundMode.SolidColor`.
    BackgroundMode mode = BackgroundMode::SolidColor;

    /// Background solid color.
    /// - Note: defaultValue ` Color(0.25, 0.25, 0.25, 1.0)`
    /// - Remark: When `mode` is `BackgroundMode.SolidColor`, the property will take effects.
    math::Color solidColor = math::Color(0.25, 0.25, 0.25, 1.0);
    
    Background(Engine* engine);
};

}

#endif /* background_hpp */
