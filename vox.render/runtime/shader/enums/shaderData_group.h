//
//  shaderData_group.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef shaderData_group_h
#define shaderData_group_h

/**
 * Shader data grouping.
 */
struct ShaderDataGroup {
    enum Enum {
        /** Scene group. */
        Scene,
        /** Camera group. */
        Camera,
        /** Renderer group. */
        Renderer,
        /** material group. */
        Material
    };
};

#endif /* shaderData_group_h */
