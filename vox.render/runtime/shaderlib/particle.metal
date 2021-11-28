//
//  particle.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/23.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.metal"

typedef struct {
    float3 a_position [[attribute(0)]];
    float3 a_velocity [[attribute(1)]];
    float3 a_acceleration [[attribute(2)]];
    float4 a_color [[attribute(3)]];
    
    float4 a_lifeAndSize [[attribute(4)]];
    float2 a_rotation [[attribute(5)]];
    
    float3 a_uv [[attribute(6)]];
    float2 a_normalizedUv [[attribute(7)]];
} VertexIn;

typedef struct {
    float4 position [[position]];
    float4 v_color;
    float v_lifeLeft;
    float2 v_uv;
} VertexOut;

matrix_float2x2 rotation2d(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    
    return matrix_float2x2(
                           c, -s,
                           s, c
                           );
}

vertex VertexOut vertex_particle(const VertexIn vertexIn [[stage_in]],
                                 constant float &u_time [[buffer(0)]],
                                 constant bool &u_once [[buffer(1)]],
                                 constant matrix_float4x4 &u_MVPMat [[buffer(2)]],
                                 constant matrix_float4x4 &u_viewInvMat [[buffer(3), function_constant(is2D)]],
                                 constant matrix_float4x4 &u_projMat [[buffer(4), function_constant(is2D)]],
                                 constant matrix_float4x4 &u_viewMat [[buffer(5), function_constant(is2D)]],
                                 constant matrix_float4x4 &u_modelMat [[buffer(6), function_constant(is2D)]]) {
    VertexOut out;
    
    out.v_color = vertexIn.a_color;
    out.v_uv = vertexIn.a_uv.xy;
    
    // life time
    float life = vertexIn.a_lifeAndSize.y;
    float startTime = vertexIn.a_lifeAndSize.x;
    
    // Elapsed time
    float deltaTime = max(fmod(u_time - startTime, life), 0.0);
    
    if ((u_once && u_time > life + startTime)) {
        deltaTime = 0.0;
    }
    
    out.v_lifeLeft = 1.0 - deltaTime / life;
    float scale = vertexIn.a_lifeAndSize.z;
    float3 position = vertexIn.a_position + (vertexIn.a_velocity + vertexIn.a_acceleration * deltaTime * 0.5) * deltaTime;
    
    if (needScaleByLifetime) {
        scale *= out.v_lifeLeft;
    } else {
        scale *= pow(vertexIn.a_lifeAndSize.w, deltaTime);
    }
    
    float angle;
    if (needRotateToVelocity) {
        float3 v = vertexIn.a_velocity + vertexIn.a_acceleration * deltaTime;
        angle = atan2(v.z, v.x) * 2.0;
    } else {
        float deltaAngle = deltaTime * vertexIn.a_rotation.y;
        angle = vertexIn.a_rotation.x + deltaAngle;
    }
    
    if (is2D) {
        float2 rotatedPoint = rotation2d(angle) * float2(vertexIn.a_normalizedUv.x, vertexIn.a_normalizedUv.y * vertexIn.a_uv.z);
        
        float3 basisX = u_viewInvMat[0].xyz;
        float3 basisZ = u_viewInvMat[1].xyz;
        
        float3 localPosition = float3(basisX * rotatedPoint.x +
                                      basisZ * rotatedPoint.y) * scale + position;
        
        out.position = u_projMat * u_viewMat * float4(localPosition + u_modelMat[3].xyz, 1.);
    } else {
        float s;
        float c;
        if (needRotateToVelocity) {
            s = sin(angle);
            c = cos(angle);
        } else {
            s = sin(angle);
            c = cos(angle);
        }
        
        float4 rotatedPoint = float4((vertexIn.a_normalizedUv.x * c + vertexIn.a_normalizedUv.y * vertexIn.a_uv.z * s) * scale , 0.,
                                     (vertexIn.a_normalizedUv.x * s - vertexIn.a_normalizedUv.y * vertexIn.a_uv.z * c) * scale, 1.);
        
        float4 orientation = float4(0, 0, 0, 1);
        float4 q2 = orientation + orientation;
        float4 qx = orientation.xxxw * q2.xyzx;
        float4 qy = orientation.xyyw * q2.xyzy;
        float4 qz = orientation.xxzw * q2.xxzz;
        
        matrix_float4x4 localMatrix = matrix_float4x4((1.0 - qy.y) - qz.z,
                                                      qx.y + qz.w,
                                                      qx.z - qy.w,
                                                      0,
                                                      
                                                      qx.y - qz.w,
                                                      (1.0 - qx.x) - qz.z,
                                                      qy.z + qx.w,
                                                      0,
                                                      
                                                      qx.z + qy.w,
                                                      qy.z - qx.w,
                                                      (1.0 - qx.x) - qy.y,
                                                      0,
                                                      
                                                      position.x, position.y, position.z, 1);
        
        rotatedPoint = localMatrix * rotatedPoint;
        
        out.position = u_MVPMat * rotatedPoint;
    }
    
    return out;
}

fragment float4 fragment_particle(VertexOut in [[stage_in]],
                                  sampler textureSampler [[sampler(0)]],
                                  texture2d<float> u_texture [[texture(0)]]) {
    if (in.v_lifeLeft == 1.0) {
        discard_fragment();
    }
    
    float alphaFactor = 1.0;
    
    if (needFadeIn) {
        float fadeInFactor = step(0.5, in.v_lifeLeft);
        alphaFactor = 2.0 * fadeInFactor * (1.0 - in.v_lifeLeft) + (1.0 - fadeInFactor);
    }
    
    if (needFadeOut) {
        float fadeOutFactor = step(0.5, in.v_lifeLeft);
        alphaFactor = alphaFactor * 2.0 * (1.0 - fadeOutFactor) * in.v_lifeLeft + alphaFactor * fadeOutFactor;
    }
    
    if (hasParticleTexture) {
        float4 tex = u_texture.sample(textureSampler, in.v_uv);
        if (needUseOriginColor) {
            return float4(tex.rgb, alphaFactor * tex.a * in.v_color.w);
        }else {
            return float4(in.v_color.xyz * tex.rgb, alphaFactor * tex.a * in.v_color.w);
        }
    } else {
        return float4( in.v_color.xyz, alphaFactor * in.v_color.w);
    }
}
