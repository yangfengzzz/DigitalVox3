//
//  render_queue_type.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_queue_type_h
#define render_queue_type_h

/// Render queue type.
struct RenderQueueType {
    enum Enum {
        /// Opaque queue.
        Opaque = 1000,
        /// Opaque queue, alpha cutoff.
        AlphaTest = 2000,
        /// Transparent queue, rendering from back to front to ensure correct rendering of transparent objects.
        Transparent = 3000
    };
};

#endif /* render_queue_type_h */
