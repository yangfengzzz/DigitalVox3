//
//  pbr_common.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/12/19.
//

#ifndef pbr_common_h
#define pbr_common_h

// Create the Environment BRDF look-up texture

// http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html

float radicalInverse_VdC(uint bits);

float2 Hammersley(uint i, uint N);

// http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float G_Smith(float roughness, float NoV, float NoL, bool ibl);
float3 ImportanceSampleGGX(float2 Xi, float Roughness, float3 N);
float2 IntegrateBRDF(float Roughness, float NoV);
float3 PrefilterEnvMap(float Roughness, float3 R,
                       texturecube<float, access::sample>EnvMap);
float3 convertUVToDirection(uint face, float2 uv);

#endif /* pbr_common_h */
