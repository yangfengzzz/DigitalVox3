//
//  particle_renderer.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/8.
//

#ifndef particle_renderer_hpp
#define particle_renderer_hpp

#include "../mesh/mesh_renderer.h"
#include "maths/color.h"
#include <random>

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
class ParticleRenderer :public MeshRenderer {
public:
    ParticleRenderer(Entity* entity);
    
    /**
     * Sprite sheet of texture.
     */
    std::vector<math::Float4> spriteSheet;
    
    /**
     * Texture of particle.
     */
    id<MTLTexture> texture();
    
    void setTexture(id<MTLTexture> texture);
    
    /**
     * Position of particles.
     */
    math::Float3 position();
    
    void setPosition(const math::Float3& value);
    
    /**
     * Random range of positions.
     */
    math::Float3 positionRandomness();
    
    void setPositionRandomness(const math::Float3& value);
    
    /**
     * Array of fixed positions.
     */
    const std::vector<math::Float3>& positionArray() const;
    
    void setPositionArray(const std::vector<math::Float3>& value);
    
    /**
     * Velocity of particles.
     */
    math::Float3 velocity();
    
    void setVelocity(const math::Float3& value);
    
    /**
     * Random range of velocity.
     */
    math::Float3 velocityRandomness();
    
    void setVelocityRandomness(const math::Float3& value);
    
    /**
     * Acceleration of particles.
     */
    math::Float3 acceleration();
    
    void setAcceleration(const math::Float3& value);
    
    /**
     * Random range of acceleration.
     */
    math::Float3 accelerationRandomness();
    
    void setAccelerationRandomness(const math::Float3& value);
    
    /**
     * Color of particles.
     */
    math::Color color();
    
    void setColor(const math::Color& value);
    
    /**
     * Random range of color.
     */
    float colorRandomness();

    void setColorRandomness(float value);

    /**
     * Size of particles.
     */
    float size();

    void setSize(float value);

    /**
     * Random range of size.
     */
    float sizeRandomness();

    void setSizeRandomness(float value);

    /**
     * Alpha of particles.
     */
    float alpha();

    void setAlpha(float value);

    /**
     * Random range of alpha.
     */
    float alphaRandomness();

    void setAlphaRandomness(float value);

    /**
     * Angle of particles.
     */
    float angle();

    void setAngle(float value);

    /**
     * Random range of angle.
     */
    float angleRandomness();

    void setAngleRandomness(float value);

    /**
     * Rotate velocity of particles.
     */
    float rotateVelocity();

    void setRotateVelocity(float value);

    /**
     * Random range of rotate velocity.
     */
    float rotateVelocityRandomness();

    void setRotateVelocityRandomness(float value);

    /**
     * Lifetime of particles.
     */
    float lifetime();

    void setLifetime(float value);

    /**
     * Random range of start time.
     */
    float startTimeRandomness();

    void setStartTimeRandomness(float value);

    /**
     * Scale factor of particles.
     */
    float scale();

    void setScale(float value);

    /**
     * Max count of particles.
     */
    size_t maxCount();

    void setMaxCount(size_t value);

    /**
     * Whether play once.
     */
    bool isOnce();

    void setIsOnce(bool value);

    /**
     * Whether follow the direction of velocity.
     */
    bool isRotateToVelocity();

    void setIsRotateToVelocity(bool value);

    /**
     * Whether use origin color.
     */
    bool isUseOriginColor();

    void setIsUseOriginColor(bool value);

    /**
     * Whether scale by lifetime.
     */
    bool isScaleByLifetime();

    void setIsScaleByLifetime(bool value);

    /**
     * Whether 2D rendering.
     */
    bool is2d();

    void setIs2d(bool value);

    /**
     * Whether fade in.
     */
    bool isFadeIn();

    void setIsFadeIn(bool value);

    /**
     * Whether fade out.
     */
    bool isFadeOut();

    void setIsFadeOut(bool value);

    /**
     * Whether play on enable.
     */
    bool playOnEnable();

    void setPlayOnEnable(bool value);

    /**
     * Blend mode of the particle renderer's material.
     */
    ParticleRendererBlendMode::Enum blendMode();

    void setBlendMode(ParticleRendererBlendMode::Enum value);
    
public:
    void update(float deltaTime) override;

    void _onEnable() override;

    /**
     * Start emitting.
     */
    void start();

    /**
     * Stop emitting.
     */
    void stop();
    
private:
    MaterialPtr _createMaterial();

    MeshPtr _createMesh();

    void _updateBuffer();

    void _updateSingleBuffer(size_t i);

    void _updateSingleUv(size_t i, size_t k0, size_t k1, size_t k2, size_t k3);
    
private:
    static float _getRandom();
    static std::default_random_engine e;
    static std::uniform_real_distribution<float> u;
    
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
