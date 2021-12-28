//
//  metal_loader.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/18.
//

#include "metal_loader.h"
#include <vector>
#include <iostream>

namespace vox {
MetalLoader::MetalLoader(id <MTLDevice> device) :
_device(device) {
    _commandQueue = [_device newCommandQueue];
    _library = [_device newDefaultLibrary];
    _textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];
}

id <MTLTexture> MetalLoader::buildTexture(MTLTextureDescriptor *descriptor) {
    return [_device newTextureWithDescriptor:descriptor];
}

id <MTLTexture> MetalLoader::buildTexture(int width, int height, MTLPixelFormat pixelFormat,
                                          MTLTextureUsage usage, MTLStorageMode storageMode) {
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:pixelFormat
                                                                                          width:width height:height
                                                                                      mipmapped:false];
    descriptor.usage = usage;
    descriptor.storageMode = storageMode;
    return [_device newTextureWithDescriptor:descriptor];
}

id <MTLTexture> MetalLoader::buildCubeTexture(int size, MTLPixelFormat pixelFormat,
                                              MTLTextureUsage usage, MTLStorageMode storageMode) {
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor textureCubeDescriptorWithPixelFormat:pixelFormat
                                                                                             size:size
                                                                                        mipmapped:false];
    descriptor.usage = usage;
    descriptor.storageMode = storageMode;
    return [_device newTextureWithDescriptor:descriptor];
}

id <MTLTexture> MetalLoader::loadTexture(const std::string &path, const std::string &imageName, bool isTopLeft) {
    NSString *pathName = [[NSString alloc] initWithUTF8String:path.c_str()];
    NSString *textureName = [[NSString alloc] initWithUTF8String:imageName.c_str()];
    NSURL *url = [[NSBundle bundleWithPath:pathName] URLForResource:textureName withExtension:nil];
    
    MTKTextureLoaderOrigin origin = MTKTextureLoaderOriginTopLeft;
    if (!isTopLeft) {
        origin = MTKTextureLoaderOriginBottomLeft;
    }
    
    NSDictionary < MTKTextureLoaderOption, id > *options = @{
        MTKTextureLoaderOptionOrigin: origin,
        MTKTextureLoaderOptionGenerateMipmaps: [NSNumber numberWithBool:TRUE]
    };
    
    NSError *error = nil;
    id <MTLTexture> texture = [_textureLoader newTextureWithContentsOfURL:url
                                                                  options:options error:&error];
    if (error != nil) {
        NSLog(@"Error: failed to create MTLTexture: %@", error);
    }
    return texture;
}

id <MTLTexture> MetalLoader::loadTexture(MDLMaterial *material, MDLMaterialSemantic materialSemantic, bool isTopLeft) {
    id <MTLTexture> texture;
    NSError *error;
    
    MTKTextureLoaderOrigin origin = MTKTextureLoaderOriginTopLeft;
    if (!isTopLeft) {
        origin = MTKTextureLoaderOriginBottomLeft;
    }
    
    NSArray<MDLMaterialProperty *> *propertiesWithSemantic =
    [material propertiesWithSemantic:materialSemantic];
    
    for (MDLMaterialProperty *property in propertiesWithSemantic) {
        if (property.type == MDLMaterialPropertyTypeString ||
            property.type == MDLMaterialPropertyTypeURL) {
            // Load the textures with shader read using private storage
            NSDictionary * textureLoaderOptions = @{
                MTKTextureLoaderOptionTextureUsage: @(MTLTextureUsageShaderRead),
                MTKTextureLoaderOptionTextureStorageMode: @(MTLStorageModePrivate),
                MTKTextureLoaderOptionOrigin: origin
            };
            
            // First will interpret the string as a file path and attempt to load it with
            //    -[MTKTextureLoader newTextureWithContentsOfURL:options:error:]
            NSURL *textureURL = property.URLValue;
            
            // Attempt to load the texture from the file system
            texture = [_textureLoader newTextureWithContentsOfURL:textureURL
                                                          options:textureLoaderOptions
                                                            error:&error];
            if (error != nil) {
                NSLog(@"Error: failed to create Metal Texture: %@", error);
            }
            // If the texture has been found for a material using the string as a file path name...
            if (texture) {
                // ...return it
                return texture;
            }
            
            // If no texture found by interpreting it as a file path or as an asset name
            // in the asset catalog, something went wrong (Perhaps the file was missing or
            // misnamed in the asset catalog, model/material file, or file system)
            
            // Depending on how the Metal render pipeline use with this submesh is implemented,
            // this condition can be handled more gracefully.  The app could load a dummy texture
            // that will look okay when set with the pipeline or ensure that the pipelines
            // rendering this submesh do not require a material with this property.
            
            [NSException raise:@"Texture data for material property not found"
                        format:@"Requested material property semantic: %lu string: %@",
             materialSemantic, property.stringValue];
        }
    }
    
    [NSException raise:@"No appropriate material property from which to create texture"
                format:@"Requested material property semantic: %lu", materialSemantic];
    
    // If we're here, this model doesn't have any textures
    return nullptr;
}

id <MTLTexture> MetalLoader::loadTexture(MDLTexture *texture) {
    NSDictionary < MTKTextureLoaderOption, id > *options = @{
        MTKTextureLoaderOptionOrigin: MTKTextureLoaderOriginBottomLeft,
        MTKTextureLoaderOptionGenerateMipmaps: [NSNumber numberWithBool:FALSE]
    };
    
    NSError *error = nil;
    id <MTLTexture> mtlTexture = [_textureLoader newTextureWithMDLTexture:texture options:options error:&error];
    if (error != nil) {
        NSLog(@"Error: failed to create MTLTexture: %@", error);
    }
    return mtlTexture;
}

id <MTLTexture> MetalLoader::loadCubeTexture(const std::string &path, const std::array<std::string, 6> &imageName, bool isTopLeft) {
    NSString *pathName = [[NSString alloc] initWithUTF8String:path.c_str()];
    NSString *textureName1 = [[NSString alloc] initWithUTF8String:imageName[0].c_str()];
    NSString *textureName2 = [[NSString alloc] initWithUTF8String:imageName[1].c_str()];
    NSString *textureName3 = [[NSString alloc] initWithUTF8String:imageName[2].c_str()];
    NSString *textureName4 = [[NSString alloc] initWithUTF8String:imageName[3].c_str()];
    NSString *textureName5 = [[NSString alloc] initWithUTF8String:imageName[4].c_str()];
    NSString *textureName6 = [[NSString alloc] initWithUTF8String:imageName[5].c_str()];
    
    NSMutableArray<NSString *> *imageNames = [[NSMutableArray alloc] init];
    [imageNames addObject:textureName1];
    [imageNames addObject:textureName2];
    [imageNames addObject:textureName3];
    [imageNames addObject:textureName4];
    [imageNames addObject:textureName5];
    [imageNames addObject:textureName6];
    
    MDLTexture *mdlTexture = [MDLTexture textureCubeWithImagesNamed:imageNames bundle:[NSBundle bundleWithPath:pathName]];
    MTKTextureLoaderOrigin origin = MTKTextureLoaderOriginTopLeft;
    if (!isTopLeft) {
        origin = MTKTextureLoaderOriginBottomLeft;
    }
    
    NSDictionary < MTKTextureLoaderOption, id > *options = @{
        MTKTextureLoaderOptionOrigin: origin,
        MTKTextureLoaderOptionGenerateMipmaps: [NSNumber numberWithBool:FALSE],
        MTKTextureLoaderOptionTextureUsage: [NSNumber numberWithUnsignedLong:MTLTextureUsageShaderRead]
    };
    NSError *error = nil;
    id <MTLTexture> mtlTexture = [_textureLoader newTextureWithMDLTexture:mdlTexture options:options error:&error];
    if (error != nil) {
        NSLog(@"Error: failed to create MTLTexture: %@", error);
    }
    return mtlTexture;
}

id <MTLTexture> MetalLoader::loadTextureArray(const std::string &path, const std::vector<std::string> &textureNames) {
    std::vector<id <MTLTexture>> textures;
    for (const auto &name: textureNames) {
        auto texture = loadTexture(path, name);
        if (texture != nil) {
            textures.push_back(texture);
        }
    }
    return createTextureArray(textures);
}

id <MTLTexture> MetalLoader::createTextureArray(const std::vector<id <MTLTexture>> &textures) {
    MTLTextureDescriptor *descriptor = [[MTLTextureDescriptor alloc] init];
    descriptor.textureType = MTLTextureType2DArray;
    descriptor.pixelFormat = textures[0].pixelFormat;
    descriptor.width = textures[0].width;
    descriptor.height = textures[0].height;
    descriptor.arrayLength = textures.size();
    descriptor.storageMode = MTLStorageModePrivate;
    
    auto arrayTexture = [_device newTextureWithDescriptor:descriptor];
    auto commandBuffer = [_commandQueue commandBuffer];
    auto blitEncoder = [commandBuffer blitCommandEncoder];
    MTLOrigin origin = MTLOrigin{.x =  0, .y =  0, .z =  0};
    MTLSize size = MTLSize{.width =  arrayTexture.width,
        .height =  arrayTexture.height, .depth = 1};
    for (size_t index = 0; index < textures.size(); index++) {
        [blitEncoder copyFromTexture:textures[index] sourceSlice:0 sourceLevel:0 sourceOrigin:origin sourceSize:size
                           toTexture:arrayTexture destinationSlice:index destinationLevel:0 destinationOrigin:origin];
    }
    [blitEncoder endEncoding];
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    return arrayTexture;
}

//MARK: - PBR Utility
id <MTLTexture> MetalLoader::createIrradianceTexture(const std::string &path,
                                                     const std::array<std::string, 6> &imageName,
                                                     float roughness, bool isDebugger, bool isTopLeft) {
    NSString *pathName = [[NSString alloc] initWithUTF8String:path.c_str()];
    NSString *textureName1 = [[NSString alloc] initWithUTF8String:imageName[0].c_str()];
    NSString *textureName2 = [[NSString alloc] initWithUTF8String:imageName[1].c_str()];
    NSString *textureName3 = [[NSString alloc] initWithUTF8String:imageName[2].c_str()];
    NSString *textureName4 = [[NSString alloc] initWithUTF8String:imageName[3].c_str()];
    NSString *textureName5 = [[NSString alloc] initWithUTF8String:imageName[4].c_str()];
    NSString *textureName6 = [[NSString alloc] initWithUTF8String:imageName[5].c_str()];
    
    NSMutableArray<NSString *> *imageNames = [[NSMutableArray alloc] init];
    [imageNames addObject:textureName1];
    [imageNames addObject:textureName2];
    [imageNames addObject:textureName3];
    [imageNames addObject:textureName4];
    [imageNames addObject:textureName5];
    [imageNames addObject:textureName6];
    
    MDLTexture *mdlTexture = [MDLTexture textureCubeWithImagesNamed:imageNames bundle:[NSBundle bundleWithPath:pathName]];
    
    auto irradianceTexture = [MDLTexture irradianceTextureCubeWithTexture:mdlTexture
                                                                     name:NULL dimensions:simd_make_int2(32, 32) roughness:roughness];
    
    MTKTextureLoaderOrigin origin = MTKTextureLoaderOriginTopLeft;
    if (!isTopLeft) {
        origin = MTKTextureLoaderOriginBottomLeft;
    }
    
    MTLTextureUsage usage = MTLTextureUsageShaderRead;
    if (isDebugger) {
        usage |= MTLTextureUsagePixelFormatView;
    }
    
    NSDictionary < MTKTextureLoaderOption, id > *options = @{
        MTKTextureLoaderOptionOrigin: origin,
        MTKTextureLoaderOptionGenerateMipmaps: [NSNumber numberWithBool:FALSE],
        MTKTextureLoaderOptionTextureUsage: [NSNumber numberWithUnsignedLong:usage]
    };
    NSError *error = nil;
    id <MTLTexture> mtlTexture = [_textureLoader newTextureWithMDLTexture:irradianceTexture options:options error:&error];
    if (error != nil) {
        NSLog(@"Error: failed to create MTLTexture: %@", error);
    }
    return mtlTexture;
}

std::array<float, 27> MetalLoader::createSphericalHarmonicsCoefficients(const std::string &path,
                                                                        const std::array<std::string, 6> &imageName) {
    NSString *pathName = [[NSString alloc] initWithUTF8String:path.c_str()];
    NSString *textureName1 = [[NSString alloc] initWithUTF8String:imageName[0].c_str()];
    NSString *textureName2 = [[NSString alloc] initWithUTF8String:imageName[1].c_str()];
    NSString *textureName3 = [[NSString alloc] initWithUTF8String:imageName[2].c_str()];
    NSString *textureName4 = [[NSString alloc] initWithUTF8String:imageName[3].c_str()];
    NSString *textureName5 = [[NSString alloc] initWithUTF8String:imageName[4].c_str()];
    NSString *textureName6 = [[NSString alloc] initWithUTF8String:imageName[5].c_str()];
    
    NSMutableArray<NSString *> *imageNames = [[NSMutableArray alloc] init];
    [imageNames addObject:textureName1];
    [imageNames addObject:textureName2];
    [imageNames addObject:textureName3];
    [imageNames addObject:textureName4];
    [imageNames addObject:textureName5];
    [imageNames addObject:textureName6];
    
    MDLTexture *mdlTexture = [MDLTexture textureCubeWithImagesNamed:imageNames bundle:[NSBundle bundleWithPath:pathName]];
    
    auto irradianceTexture = [MDLTexture irradianceTextureCubeWithTexture:mdlTexture
                                                                     name:NULL dimensions:simd_make_int2(64, 64) roughness:0];
    
    MDLLightProbe *lightProbe = [[MDLLightProbe alloc] initWithReflectiveTexture:mdlTexture irradianceTexture:irradianceTexture];
    [lightProbe generateSphericalHarmonicsFromIrradiance:2];
    float *coeffs = (float *) lightProbe.sphericalHarmonicsCoefficients.bytes;
    
    std::array<float, 27> result;
    std::copy(coeffs, coeffs + 27, result.data());
    return result;
}

id <MTLTexture> MetalLoader::createBRDFLookupTable() {
    auto brdfFunction = [_library newFunctionWithName:@"integrateBRDF"];
    NSError *error = nil;
    auto brdfPipelineState = [_device newComputePipelineStateWithFunction:brdfFunction error:&error];
    if (error != nil) {
        NSLog(@"Error: failed to create Metal pipeline state: %@", error);
    }
    auto commandBuffer = [_commandQueue commandBuffer];
    auto commandEncoder = [commandBuffer computeCommandEncoder];
    
    const uint32_t size = 256;
    auto descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRG16Float
                                                                         width:size height:size mipmapped:false];
    descriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
    auto lut = [_device newTextureWithDescriptor:descriptor];
    
    [commandEncoder setComputePipelineState:brdfPipelineState];
    [commandEncoder setTexture:lut atIndex:0];
    auto threadsPerThreadgroup = MTLSizeMake(16, 16, 1);
    auto threadgroups = MTLSizeMake(size / threadsPerThreadgroup.width,
                                    size / threadsPerThreadgroup.height, 1);
    [commandEncoder dispatchThreadgroups:threadgroups threadsPerThreadgroup:threadsPerThreadgroup];
    [commandEncoder endEncoding];
    [commandBuffer commit];
    return lut;
}

id <MTLTexture> MetalLoader::createSpecularTexture(const std::string &path,
                                                   const std::array<std::string, 6> &imageName,
                                                   bool isDebugger, bool isTopLeft) {
    id <MTLTexture> mtlTexture = loadCubeTexture(path, imageName, isTopLeft);
    
    // final texture
    MTLTextureUsage usage = MTLTextureUsageShaderRead;
    if (isDebugger) {
        usage |= MTLTextureUsagePixelFormatView;
    }
    
    MTLTextureDescriptor *descriptor = [[MTLTextureDescriptor alloc] init];
    descriptor.textureType = MTLTextureTypeCube;
    descriptor.pixelFormat = mtlTexture.pixelFormat;
    descriptor.width = mtlTexture.width;
    descriptor.height = mtlTexture.height;
    descriptor.mipmapLevelCount = 9;
    descriptor.usage = usage;
    auto specularTexture = [_device newTextureWithDescriptor:descriptor];
    
    // merge
    NSError *error = nil;
    auto function = [_library newFunctionWithName:@"build_specular"];
    auto pipelineState = [_device newComputePipelineStateWithFunction:function error:&error];
    if (error != nil) {
        NSLog(@"Error: failed to create Metal pipeline state: %@", error);
    }
    auto commandBuffer = [_commandQueue commandBuffer];
    
    auto blitEncoder = [commandBuffer blitCommandEncoder];
    [blitEncoder copyFromTexture:mtlTexture sourceSlice:0 sourceLevel:0
                       toTexture:specularTexture destinationSlice:0 destinationLevel:0 sliceCount:6 levelCount:1];
    [blitEncoder endEncoding];
    
    // generate Mipmap
    for (int level = 1; level < 9; level++) {
        std::cout << "Processing level: " << level << std::endl;
        auto commandEncoder = [commandBuffer computeCommandEncoder];
        
        auto size = mtlTexture.width / int(pow(2, float(level)));
        auto descriptor = [MTLTextureDescriptor textureCubeDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                size:size mipmapped:false];
        descriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
        auto outputTexture = [_device newTextureWithDescriptor:descriptor];
        
        [commandEncoder setComputePipelineState:pipelineState];
        [commandEncoder setTexture:mtlTexture atIndex:0];
        [commandEncoder setTexture:outputTexture atIndex:1];
        
        float roughness = float(level) / 10;
        [commandEncoder setBytes:&roughness length:sizeof(float) atIndex:0];
        auto threadsPerThreadgroup = MTLSizeMake(std::min<size_t>(size, 16), std::min<size_t>(size, 16), 1);
        auto threadgroups = MTLSizeMake(mtlTexture.width / threadsPerThreadgroup.width,
                                        mtlTexture.width / threadsPerThreadgroup.height, 6);
        [commandEncoder dispatchThreadgroups:threadgroups threadsPerThreadgroup:threadsPerThreadgroup];
        [commandEncoder endEncoding];
        
        // merge together
        auto blitEncoder = [commandBuffer blitCommandEncoder];
        [blitEncoder copyFromTexture:outputTexture sourceSlice:0 sourceLevel:0
                           toTexture:specularTexture destinationSlice:0 destinationLevel:level sliceCount:6 levelCount:1];
        [blitEncoder endEncoding];
    }
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    return specularTexture;
}

id <MTLTexture> MetalLoader::createMetallicRoughnessTexture(const std::string &path, const std::string &metallic,
                                                            const std::string &roughness, bool isTopLeft) {
    auto metallicTex = loadTexture(path, metallic, isTopLeft);
    auto roughnessTex = loadTexture(path, roughness, isTopLeft);
    
    MTLTextureDescriptor *descriptor = [[MTLTextureDescriptor alloc] init];
    descriptor.textureType = MTLTextureType2D;
    descriptor.pixelFormat = metallicTex.pixelFormat;
    descriptor.width = metallicTex.width;
    descriptor.height = metallicTex.height;
    descriptor.usage = metallicTex.usage | MTLTextureUsageShaderWrite;
    auto mergedTexture = [_device newTextureWithDescriptor:descriptor];
    
    // merge
    NSError *error = nil;
    auto function = [_library newFunctionWithName:@"build_metallicRoughness"];
    auto pipelineState = [_device newComputePipelineStateWithFunction:function error:&error];
    if (error != nil) {
        NSLog(@"Error: failed to create Metal pipeline state: %@", error);
    }
    auto commandBuffer = [_commandQueue commandBuffer];
    auto commandEncoder = [commandBuffer computeCommandEncoder];
    
    [commandEncoder setComputePipelineState:pipelineState];
    [commandEncoder setTexture:metallicTex atIndex:0];
    [commandEncoder setTexture:roughnessTex atIndex:1];
    [commandEncoder setTexture:mergedTexture atIndex:2];
    
    auto size = metallicTex.width;
    auto threadsPerThreadgroup = MTLSizeMake(std::min<size_t>(size, 16), std::min<size_t>(size, 16), 1);
    auto threadgroups = MTLSizeMake(metallicTex.width / threadsPerThreadgroup.width,
                                    metallicTex.width / threadsPerThreadgroup.height, 1);
    [commandEncoder dispatchThreadgroups:threadgroups threadsPerThreadgroup:threadsPerThreadgroup];
    [commandEncoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    return mergedTexture;
}

//MARK: - MTLBuffer
id <MTLBuffer> MetalLoader::buildBuffer(const void *pointer, size_t length, MTLResourceOptions options) {
    return [_device newBufferWithBytes:pointer length:NSUInteger(length) options:options];
}

id <MTLBuffer> MetalLoader::buildBuffer(size_t length, MTLResourceOptions options) {
    return [_device newBufferWithLength:NSUInteger(length) options:options];
}

}
