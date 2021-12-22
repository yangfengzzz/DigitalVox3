//
//  shader_common.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/11/28.
//

#ifndef shader_common_h
#define shader_common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef enum {
    unused = 0,
    Sunlight = 1,
    Spotlight = 2,
    Pointlight = 3,
    Ambientlight = 4
} LightType;

typedef struct {
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float intensity;
    vector_float3 attenuation;
    LightType type;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
} Light;

typedef enum {
    Position = 0,
    Normal = 1,
    UV_0 = 2,
    Tangent = 3,
    Bitangent = 4,
    Color_0 = 5,
    Weights_0 = 6,
    Joints_0 = 7,
    UV_1 = 8,
    UV_2 = 9,
    UV_3 = 10,
    UV_4 = 11,
    UV_5 = 12,
    UV_6 = 13,
    UV_7 = 14,
} Attributes;

typedef enum {
    BaseColorTexture = 0,
    NormalTexture = 1
} Textures;

typedef enum {
    BufferIndexVertices = 0,
    BufferIndexUniforms = 15,
    BufferIndexLights = 16,
    BufferIndexFragmentUniforms = 17,
    BufferIndexMaterials = 18
} BufferIndices;

typedef struct {
    vector_float3 baseColor;
    vector_float3 specularColor;
    float roughness;
    float metallic;
    vector_float3 ambientOcclusion;
    float shininess;
} MaterialConstant;

typedef struct {
    vector_float3 diffuse;
    float diffuseIntensity;
    float specularIntensity;
    int mipMapLevel;
    matrix_float4x4 transformMatrix;
} EnvMapLight;

struct ShadowData {
    /**
     * Shadow bias.
     */
    float bias = 0.005;
    /**
     * Shadow intensity, the larger the value, the clearer and darker the shadow.
     */
    float intensity = 0.2;
    /**
     * Pixel range used for shadow PCF interpolation.
     */
    float radius = 1;
    /**
     * Light view projection matrix.
     */
    matrix_float4x4 vp;
};

#endif /* shader_common_h */
