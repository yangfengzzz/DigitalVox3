//
//  particle_renderer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#ifndef particle_renderer_hpp
#define particle_renderer_hpp

#include "../renderer.h"
#include "maths/color.h"

namespace vox {
struct DirtyFlagType {
    enum Enum {
        Position = 0x1,
        Velocity = 0x2,
        Acceleration = 0x4,
        Color = 0x8,
        Alpha = 0x10,
        Size = 0x20,
        StartAngle = 0x40,
        StartTime = 0x80,
        LifeTime = 0x100,
        RotateVelocity = 0x200,
        Scale = 0x400,
        Everything = 0xffffffff
    };
};

/**
 * Blend mode enums of the particle renderer's material.
 */
struct ParticleRendererBlendMode {
    enum Enum {
        Transparent = 0,
        Additive = 1
    };
};

/**
 * Particle Renderer Component.
 */
class ParticleRenderer :public Renderer {
public:
    /**
     * Texture of particle.
     */
    id<MTLTexture> texture();

    void setTexture(id<MTLTexture> texture);
    
private:
    /** The max number of indices that Uint16Array can support. */
    static size_t _uint16VertexLimit;
    
    static float _getRandom();
    
    uint32_t _vertexStride;
    std::vector<float> _vertices;
    id<MTLBuffer> _vertexBuffer;
    size_t _maxCount = 1000;
    math::Float3 _position;
    math::Float3 _positionRandomness;
    std::vector<math::Float3> _positionArray;
    math::Float3 _velocity;
    math::Float3 _velocityRandomness;
    math::Float3 _acceleration;
    math::Float3 _accelerationRandomness;
    math::Color _color = math::Color(1, 1, 1, 1);
    float _colorRandomness = 0;
    float _size = 1;
    float _sizeRandomness = 0;
    float _alpha = 1;
    float _alphaRandomness = 0;
    float _startAngle = 0;
    float _startAngleRandomness = 0;
    float _rotateVelocity = 0;
    float _rotateVelocityRandomness = 0;
    float _lifetime = 5;
    float _startTimeRandomness = 0;
    float _scale = 1;
    bool _isOnce = false;
    float _onceTime = 0;
    float _time = 0;
    bool _isInit = false;
    bool _isStart = false;
    int _updateDirtyFlag = DirtyFlagType::Enum::Everything;
    bool _isRotateToVelocity = false;
    bool _isUseOriginColor = false;
    bool _isScaleByLifetime = false;
    bool _is2d = true;
    bool _isFadeIn = false;
    bool _isFadeOut = false;
    bool _playOnEnable = true;
    ParticleRendererBlendMode::Enum _blendMode = ParticleRendererBlendMode::Enum::Transparent;
};

}

#endif /* particle_renderer_hpp */
