//
//  background.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/28.
//

#ifndef background_hpp
#define background_hpp

#include "vox_type.h"
#include "maths/color.h"
#include "sky/sky.h"

namespace vox {
/**
 * The Background mode enumeration.
 */
struct BackgroundMode {
    enum Enum {
        /* Solid color. */
        SolidColor,
        /* Sky. */
        Sky,
        /** Texture */
        Texture
    };
};

/**
 * Background of scene.
 */
class Background {
public:
    /**
     * Background mode.
     * @defaultValue `BackgroundMode.SolidColor`
     * @remarks If using `BackgroundMode.Sky` mode and material or mesh of the `sky` is not defined, it will downgrade to `BackgroundMode.SolidColor`.
     */
    BackgroundMode::Enum mode = BackgroundMode::Enum::SolidColor;
    
    /**
     * Background solid color.
     * @defaultValue `new Color(0.25, 0.25, 0.25, 1.0)`
     * @remarks When `mode` is `BackgroundMode.SolidColor`, the property will take effects.
     */
    math::Color solidColor = math::Color(0.25, 0.25, 0.25, 1.0);
    
    /**
     * Background sky.
     * @remarks When `mode` is `BackgroundMode.Sky`, the property will take effects.
     */
    Sky sky = Sky();
    
    Background(Engine *engine);
};

}

#endif /* background_hpp */
